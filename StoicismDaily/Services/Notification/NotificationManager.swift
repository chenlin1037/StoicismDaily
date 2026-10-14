import Foundation
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false
    @Published var reminderTime = UserDefaults.standard.object(forKey: "ReminderTime") as? Date ?? Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    @Published var isEnabled = UserDefaults.standard.bool(forKey: "NotificationsEnabled")
    
    private var schedulingTask: Task<Void, Never>?

    private init() {
        checkAuthorization()
    }

    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
                if self.isEnabled && self.isAuthorized {
                    self.scheduleWeeklyNotifications()
                }
            }
        }
    }

    func requestAuthorization() async {
        let granted = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        self.isAuthorized = granted ?? false
        if !(granted ?? false) {
            self.isEnabled = false
            UserDefaults.standard.set(false, forKey: "NotificationsEnabled")
            cancelAllNotifications()
        }
    }

    func toggleNotifications(enabled: Bool) {
        self.isEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "NotificationsEnabled")

        if enabled {
            scheduleWeeklyNotifications()
        } else {
            cancelAllNotifications()
        }
    }

    func updateReminderTime(_ time: Date) {
        self.reminderTime = time
        UserDefaults.standard.set(time, forKey: "ReminderTime")
        if isEnabled {
            scheduleWeeklyNotifications()
        }
    }

    /// 核心方法：预约未来 7 天的通知
    func scheduleWeeklyNotifications() {
        schedulingTask?.cancel()
        guard isEnabled, isAuthorized else { return }

        // 1. 清除之前所有待发的通知，确保重新排程
        cancelAllNotifications()
        
        schedulingTask = Task {
            do {
                // 2. 加载名言库
                let quotes = try await QuoteLoader.loadQuotes()
                guard !quotes.isEmpty else { return }
                
                let calendar = Calendar.current
                let center = UNUserNotificationCenter.current()
                
                // 提取用户设置的小时和分钟
                let selectedHour = calendar.component(.hour, from: reminderTime)
                let selectedMinute = calendar.component(.minute, from: reminderTime)

                // 3. 循环创建 7 条通知
                for dayOffset in 0..<7 {
                    try Task.checkCancellation()
                    // 计算目标日期：今天 + dayOffset 天
                    guard let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: Date()) else { continue }
                    
                    // 构造该天的触发时间组件
                    var components = DateComponents()
                    components.hour = selectedHour
                    components.minute = selectedMinute
                    components.day = calendar.component(.day, from: targetDate)
                    components.month = calendar.component(.month, from: targetDate)
                    components.year = calendar.component(.year, from: targetDate)

                    // 4. 配置通知内容
                    let content = UNMutableNotificationContent()
                    content.title = "Daily Stoic Wisdom"
                    
                    // 策略：按顺序取名言，如果 offset 超过数组长度则取模
                    let quote = quotes[dayOffset % quotes.count]
                    content.body = quote.quote
                    content.sound = .default

                    // 5. 创建触发器和请求
                    // identifier 必须唯一（例如 Daily_0, Daily_1...）
                    let identifier = "DailyQuote_Day_\(dayOffset)"
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                    // 6. 添加到系统
                    try await center.add(request)
                }
            } catch {
                if !Task.isCancelled {
                    NSLog("Failed to schedule notifications: %@", error.localizedDescription)
                }
            }
        }
    }

    func cancelAllNotifications() {
        schedulingTask?.cancel()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
