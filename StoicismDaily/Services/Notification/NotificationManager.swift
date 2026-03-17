import Foundation
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false
    @Published var reminderTime = UserDefaults.standard.object(forKey: "ReminderTime") as? Date ?? Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    @Published var isEnabled = UserDefaults.standard.bool(forKey: "NotificationsEnabled")
    @Published var dailyQuote: StoicQuote?
    @Published var errorMessage: String?
    
    // 备份数据，避免网络失败时无法推送
    private var lastSuccessfulQuote: StoicQuote?

    private init() {
        checkAuthorization()
    }

    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    func requestAuthorization() async {
        let granted = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        self.isAuthorized = granted ?? false
        if !(granted ?? false) { self.isEnabled = false }
    }

    func toggleNotifications(enabled: Bool) {
        self.isEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "NotificationsEnabled")

        if enabled {
            // 开启时立即尝试获取数据并调度
            Task {
                await fetchQuote()
                scheduleDailyNotification()
            }
        } else {
            cancelAllNotifications()
        }
    }

    func updateReminderTime(_ time: Date) {
        self.reminderTime = time
        UserDefaults.standard.set(time, forKey: "ReminderTime")
        if isEnabled {
            // 修改时间时，也需要重新获取最新数据并调度
            Task {
                await fetchQuote()
                scheduleDailyNotification()
            }
        }
    }

    func fetchQuote() async {
        errorMessage = nil
        do {
            let quotes = try await QuoteLoader.loadQuotes()
            if let first = quotes.first {
                self.dailyQuote = first
                self.lastSuccessfulQuote = first 
            }
        } catch {
            self.errorMessage = "Failed to load quote."
        }
    }

    func scheduleDailyNotification() {
        // 核心优化：确保数据已准备好
        // 如果 dailyQuote 和 lastSuccessfulQuote 都为空，则不调度，或者在此处做防御性编程
        let quoteToUse = dailyQuote ?? lastSuccessfulQuote
        
        cancelAllNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Stoic Wisdom"
        // 如果确实取不到任何数据，才使用欢迎语作为底线防御
        content.body = quoteToUse?.quote ?? "Welcome to your daily Stoic journey. Open the app for your wisdom."
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "DailyQuoteReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                // 只有调度成功才重置，避免循环获取
                DispatchQueue.main.async { self.dailyQuote = nil }
            }
        }
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}