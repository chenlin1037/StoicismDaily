//
//  FavoriteQuoteManager.swift
//  StoicismDaily
//
//  收藏名言业务逻辑：委托 Store 持久化
//

import Foundation
import SwiftData

@MainActor
final class FavoriteQuoteManager: ObservableObject {
    static let shared = FavoriteQuoteManager()
    @Published private(set) var favorites: [StoicQuote] = []

    private var modelContext: ModelContext?

    private init() {}

    func setup(context: ModelContext) {
        modelContext = context
        fetchFavorites()
    }

    func fetchFavorites() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<StoicQuote>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        do {
            favorites = try context.fetch(descriptor)
        } catch {
            print("Fetch failed: \(error)")
        }
    }

    @discardableResult
    func toggleFavorite(_ quote: StoicQuote) -> Bool {
        guard let context = modelContext else { return false }

        let isNowFavorite: Bool
        if let existingQuote = favorites.first(where: { $0.author == quote.author && $0.quote == quote.quote }) {
            context.delete(existingQuote)
            isNowFavorite = false
        } else {
            let newFavorite = StoicQuote(author: quote.author, quote: quote.quote)
            context.insert(newFavorite)
            isNowFavorite = true
        }

        try? context.save()
        fetchFavorites()
        return isNowFavorite
    }

    func removeFavorites(at offsets: IndexSet) {
        guard let context = modelContext else { return }
        for index in offsets {
            context.delete(favorites[index])
        }
        try? context.save()
        fetchFavorites()
    }

    func removeAllFavorites() {
        guard let context = modelContext else { return }
        do {
            try context.delete(model: StoicQuote.self)
            try context.save()
            fetchFavorites()
        } catch {
            print("Delete all failed: \(error)")
        }
    }
}
