import Foundation
import SwiftUI

@MainActor
final class StoicQuoteViewModel: ObservableObject {
    @Published var currentQuote: StoicQuote?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var aiErrorMessage: String?
    @Published var hearts: [FavoriteHeart] = []
    @Published var dragOffset: CGFloat = 0
    @Published var isExplaining: Bool = false

    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""

    private let favoriteManager = FavoriteQuoteManager.shared
    private var toastTask: Task<Void, Never>?

    func fetchQuote() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            let quotes = try await QuoteLoader.loadQuotes()
            currentQuote = quotes.first
        } catch {
            // 更新错误提示
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func addHeart(at location: CGPoint) -> Bool {
        guard let quote = currentQuote, !isLoading else {
            return false
        }

        let isFavoriteNow = favoriteManager.toggleFavorite(quote)

        if isFavoriteNow {
            if hearts.count >= 5 {
                hearts.removeFirst(hearts.count - 4)
            }
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
        generator.prepare()
        generator.notificationOccurred(.success)

        toastTask?.cancel()
        toastTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .seconds(2))
                self?.showToast = false
            } catch {
                // A cancelled toast timer should not change the current toast state.
            }
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

    func fetchAIExplanation() async {
        guard let quote = currentQuote, quote.aiExplanation == nil else { return }

        guard !isExplaining else { return }
        isExplaining = true
        aiErrorMessage = nil
        do {
            let explanation = try await LongCatAIService.shared.fetchExplanation(for: quote.quote, author: quote.author)
            quote.aiExplanation = explanation
            // Trigger UI update
            objectWillChange.send()
        } catch {
            aiErrorMessage = error.localizedDescription
        }
        isExplaining = false
    }
}
