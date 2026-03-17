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
final class StoicQuote: Codable,Sendable, Hashable {
    var author: String
    var quote: String
    var createdAt: Date = Date()

    init(author: String, quote: String) {
        self.author = author
        self.quote = quote
        createdAt = Date()
    }

    // Codable conformance
    enum CodingKeys: String, CodingKey {
        case author
        case quote
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        author = try container.decode(String.self, forKey: .author)
        quote = try container.decode(String.self, forKey: .quote)
        createdAt = Date()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(author, forKey: .author)
        try container.encode(quote, forKey: .quote)
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
