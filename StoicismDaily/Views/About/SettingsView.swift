import SwiftUI

struct SettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section(header: Text("Content")) {
                NavigationLink(destination: ReflectionHistoryView()) {
                    Text("Reflection History")
                }
            }

            Section(header: Text("Reminder Settings")) {
                Toggle("Daily Reminder", isOn: Binding(
                    get: { notificationManager.isEnabled },
                    set: { notificationManager.toggleNotifications(enabled: $0) }
                ))
                .onChange(of: notificationManager.isEnabled) { _, newValue in
                    if newValue && !notificationManager.isAuthorized {
                        Task {
                            await notificationManager.requestAuthorization()
                        }
                    }
                }

                if notificationManager.isEnabled {
                    DatePicker("Reminder Time", selection: Binding(
                        get: { notificationManager.reminderTime },
                        set: { notificationManager.updateReminderTime($0) }
                    ), displayedComponents: .hourAndMinute)
                }
            }

            Section(footer: Text("Once enabled, you will receive a daily Stoic quote at your selected time.")) {
                if !notificationManager.isAuthorized && notificationManager.isEnabled {
                    Button("Enable Notifications in Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}
