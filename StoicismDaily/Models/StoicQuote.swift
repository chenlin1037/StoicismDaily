import Foundation
import SwiftData

struct StoicQuoteResponse: Decodable {
    struct QuoteData: Decodable {
        let author: String
        let quote: String
    }

    let data: QuoteData
}

@Model
final class StoicQuote: Codable, @unchecked Sendable, Hashable {
    var author: String
    var quote: String
    var createdAt: Date = Date()
    var aiExplanation: String?

    init(author: String, quote: String, aiExplanation: String? = nil) {
        self.author = author
        self.quote = quote
        self.aiExplanation = aiExplanation
        createdAt = Date()
    }

    // Codable conformance
    enum CodingKeys: String, CodingKey {
        case author
        case quote
        case aiExplanation
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        author = try container.decode(String.self, forKey: .author)
        quote = try container.decode(String.self, forKey: .quote)
        aiExplanation = try container.decodeIfPresent(String.self, forKey: .aiExplanation)
        createdAt = Date()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(author, forKey: .author)
        try container.encode(quote, forKey: .quote)
        try container.encodeIfPresent(aiExplanation, forKey: .aiExplanation)
    }

    // Hashable conformance
    static func == (lhs: StoicQuote, rhs: StoicQuote) -> Bool {
        lhs.author == rhs.author && lhs.quote == rhs.quote
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(author)
        hasher.combine(quote)
    }
}
