//
//  FavoritesViewModel.swift
//  StoicismDaily
//
//  Created by luckly on 2026/3/9.
//

import Combine
import Foundation

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published private(set) var favorites: [StoicQuote] = []
    @Published var searchText = ""
    @Published var selectedAuthor: String? = nil
    @Published var isSearchActive = false

    var filteredFavorites: [StoicQuote] {
        let list = favorites.filter { quote in
            let matchesSearch = searchText.isEmpty ||
                quote.quote.localizedCaseInsensitiveContains(searchText) ||
                quote.author.localizedCaseInsensitiveContains(searchText)

            let matchesAuthor = selectedAuthor == nil || quote.author == selectedAuthor

            return matchesSearch && matchesAuthor
        }
        return list
    }

    var allAuthors: [String] {
        Array(Set(favorites.map { $0.author })).sorted()
    }

    private let favoriteManager = FavoriteQuoteManager.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        favorites = favoriteManager.favorites

        // 订阅 Manager 的变化，保持同步
        favoriteManager.$favorites
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newFavorites in
                self?.favorites = newFavorites
            }
            .store(in: &cancellables)
    }

    func toggleFavorite(for quote: StoicQuote) {
        favoriteManager.toggleFavorite(quote)
    }

    func removeFavorites(at offsets: IndexSet) {
        // 由于 offsets 是相对于 filteredFavorites 的，我们需要找到原 favorites 中的对应对象进行删除
        let filtered = filteredFavorites
        let quotesToRemove = offsets.map { filtered[$0] }

        for quote in quotesToRemove {
            if let index = favorites.firstIndex(where: { $0.id == quote.id }) {
                favoriteManager.removeFavorites(at: IndexSet(integer: index))
            }
        }
    }

    func removeAllFavorites() {
        favoriteManager.removeAllFavorites()
    }
}
