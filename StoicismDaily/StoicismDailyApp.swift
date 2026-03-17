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

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(quoteViewModel)
                .environmentObject(favoritesViewModel)
        }
        .modelContainer(for: [StoicQuote.self])
    }
}
