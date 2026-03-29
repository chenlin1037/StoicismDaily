import Combine
import Foundation
import SwiftData

@MainActor
class ReflectionViewModel: ObservableObject {
    @Published var reflectionText: String = ""
    @Published var currentReflection: DailyReflection?
    @Published var isLoading = false

    private var modelContext: ModelContext?

    func setContext(_ context: ModelContext) {
        modelContext = context
    }

    func fetchTodayReflection(quote: StoicQuote?) {
        guard let context = modelContext, let quote = quote else { return }

        let quoteText = quote.quote
        let descriptor = FetchDescriptor<DailyReflection>(
            predicate: #Predicate<DailyReflection> { reflection in
                reflection.quoteContent == quoteText
            }
        )

        do {
            let reflections = try context.fetch(descriptor)
            if let existing = reflections.first {
                currentReflection = existing
                reflectionText = existing.reflectionText
            } else {
                currentReflection = nil
                reflectionText = ""
            }
        } catch {
            print("Failed to fetch reflection: \(error)")
        }
    }

    func saveReflection(quote: StoicQuote) {
        guard let context = modelContext else { return }

        if let existing = currentReflection {
            existing.reflectionText = reflectionText
            existing.updatedAt = Date()
        } else {
            let newReflection = DailyReflection(
                quoteContent: quote.quote,
                quoteAuthor: quote.author,
                reflectionText: reflectionText
            )
            context.insert(newReflection)
            currentReflection = newReflection
        }

        try? context.save()
    }
    
   
}
