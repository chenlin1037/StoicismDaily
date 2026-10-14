import Combine
import Foundation
import SwiftData

@MainActor
class ReflectionViewModel: ObservableObject {
    @Published var reflectionText: String = ""
    @Published var currentReflection: DailyReflection?
    @Published var isLoading = false
    @Published var errorMessage: String?

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
            errorMessage = "Unable to load this reflection: \(error.localizedDescription)"
        }
    }

    @discardableResult //不关心返回值，只关心是否保存成功，使用@discardableResult修饰符
    func saveReflection(quote: StoicQuote) -> Bool {
        guard let context = modelContext else {
            errorMessage = "Reflection storage is unavailable. Please try again."
            return false
        }

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

        do {
            try context.save()
            errorMessage = nil
            return true
        } catch {
            errorMessage = "Unable to save this reflection: \(error.localizedDescription)"
            return false
        }
    }
    
   
}
