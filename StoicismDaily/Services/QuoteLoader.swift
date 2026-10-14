//
//  QuoteLoader.swift
//  StoicismDaily
//
//  名言加载服务：从 https://stoic.tekloon.net/stoic-quote 接口获取名言列表
//

import Foundation

enum QuoteLoadingError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)
    case emptyQuote

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The quote service returned an invalid response. Please try again."
        case .httpStatus(let statusCode):
            return "The quote service is temporarily unavailable (\(statusCode)). Please try again."
        case .emptyQuote:
            return "The quote service returned an empty quote. Please try again."
        }
    }
}

enum QuoteLoader {
    static func loadQuotes() async throws -> [StoicQuote] {
        guard let url = URL(string: "https://stoic.tekloon.net/stoic-quote") else {
            throw QuoteLoadingError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw QuoteLoadingError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw QuoteLoadingError.httpStatus(httpResponse.statusCode)
        }

        let decoded = try JSONDecoder().decode(StoicQuoteResponse.self, from: data)
        guard !decoded.data.quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !decoded.data.author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw QuoteLoadingError.emptyQuote
        }
        let quote = StoicQuote(author: decoded.data.author,
                               quote: decoded.data.quote)
        return [quote]
    }
}

