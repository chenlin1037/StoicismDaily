//
//  StoicismDailyApp.swift
//  StoicismDaily
//
//  Created by luckly on 2026/2/24.
//

import SwiftData
import SwiftUI

@main
struct StoicismDailyApp: App {
    @StateObject private var quoteViewModel = StoicQuoteViewModel()
    @StateObject private var favoritesViewModel = FavoritesViewModel()

    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var notificationManager = NotificationManager.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(quoteViewModel)
                .environmentObject(favoritesViewModel)
        }
        .modelContainer(for: [StoicQuote.self])
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // 当 App 变为活跃状态（启动或从后台切回）时
                if notificationManager.isEnabled {
                    print("App 激活：正在刷新未来 7 天的名言通知...")
                    notificationManager.scheduleWeeklyNotifications()
                }
            }
        }
    }
}
