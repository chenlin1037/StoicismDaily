import Foundation
import SwiftUI

@MainActor
final class StoicQuoteViewModel: ObservableObject {
    @Published var currentQuote: StoicQuote?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var hearts: [FavoriteHeart] = []
    @Published var dragOffset: CGFloat = 0

    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""

    private let favoriteManager = FavoriteQuoteManager.shared

    init() {
        Task { await fetchQuote() }
    }

    func fetchQuote() async {
        isLoading = true
        errorMessage = nil

        do {
            let quotes = try await QuoteLoader.loadQuotes()
            currentQuote = quotes.first
        } catch {
            // 更新错误提示
            errorMessage = "Failed to load quote, please try again later."
        }

        isLoading = false
    }

    func addHeart(at location: CGPoint) -> Bool {
        guard let quote = currentQuote, !isLoading else {
            return false
        }

        let isFavoriteNow = favoriteManager.toggleFavorite(quote)

        if isFavoriteNow {
            let newHeart = FavoriteHeart(location: location)
            hearts.append(newHeart)
            // 更新收藏提示
            toastMessage = "Added to favorites"
        } else {
            // 更新取消收藏提示
            toastMessage = "Removed from favorites"
        }

        showToast = true

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        Task {
            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            showToast = false
        }

        return true
    }

    func removeHeart(id: UUID) {
        hearts.removeAll { $0.id == id }
    }

    func handleSwipe(h: CGFloat, v: CGFloat) {
        guard abs(h) > abs(v) else { return }

        if h < -80 {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            Task {
                await fetchQuote()
            }
        }
    }
}