import Foundation

struct AIResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let content: String
        }

        let message: Message
    }

    let choices: [Choice]
}

class LongCatAIService {
    static let shared = LongCatAIService()
    private let apiKey = "ak_1R36wg0Yi4C77Dj9LH6ot06t44C4R"
    private let url = URL(string: "https://api.longcat.chat/openai/v1/chat/completions")!

    func fetchExplanation(for quote: String, author: String) async throws -> String {
        let prompt = "请作为一名斯多葛学派导师，深度解读以下名言，并给出在现代生活中实践的建议。名言：\"\(quote)\" —— \(author)。请直接输出解读内容，不要带前缀。"

        let body: [String: Any] = [
            "model": "LongCat-Flash-Chat",
            "messages": [
                ["role": "user", "content": prompt],
            ],
            "max_tokens": 1000,
            "temperature": 0.7,
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AIResponse.self, from: data)
        return response.choices.first?.message.content ?? "无法获取AI解读。"
    }
}
