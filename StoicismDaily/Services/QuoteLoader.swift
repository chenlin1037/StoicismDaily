//
//  QuoteLoader.swift
//  StoicismDaily
//
//  名言加载服务：从 https://stoic.tekloon.net/stoic-quote 接口获取名言列表
//

import Foundation

class QuoteLoader {
    static func loadQuotes() async throws -> [StoicQuote] {
        let url = URL(string: "https://stoic.tekloon.net/stoic-quote")!
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(StoicQuoteResponse.self, from: data)
        let quote = StoicQuote(author: decoded.data.author,
                               quote: decoded.data.quote)
        return [quote]
    }
}

