import Foundation
import SwiftData

@Model
final class DailyReflection: Identifiable {
    var id: UUID = UUID()
    var date: Date = Date()
    var quoteContent: String
    var quoteAuthor: String
    var reflectionText: String
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    init(quoteContent: String, quoteAuthor: String, reflectionText: String) {
        self.quoteContent = quoteContent
        self.quoteAuthor = quoteAuthor
        self.reflectionText = reflectionText
        date = Calendar.current.startOfDay(for: Date())
        createdAt = Date()
        updatedAt = Date()
    }
}
