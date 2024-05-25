//
//  OpenAIManager.swift
//  Kiwee
//
//  Created by NY on 2024/4/22.
//

import Foundation

class OpenAIManager {
    private let apiKey: String
    private let model: String
    private let systemMessage: Message
    private let temperature: Double

    init(
        apiKey: String,
        model: String = "gpt-3.5-turbo",
        systemPrompt: String = "你是一個有幫助的助手",
        temperature: Double = 1
    ) {
        self.apiKey = apiKey
        self.model = model
        self.systemMessage = .init(role: .system, content: systemPrompt)
        self.temperature = temperature
    }
    
    private let urlSession = URLSession.shared
    private var urlRequest: URLRequest {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        return urlRequest
    }
    private var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
    }
    private let jsonDecoder = JSONDecoder()

    private var historyList: [Message] = []

    private func jsonBody(text: String, stream: Bool = true) throws -> Data {
        let request = Request(
            model: model,
            messages: generateMessages(from: text),
            temperature: temperature,
            stream: stream
        )
        return try JSONEncoder().encode(request)
    }

    /// 產生請求訊息陣列
    private func generateMessages(from text: String) -> [Message] {
        // 系統訊息+歷史訊息+新的提問訊息
        var messages = [systemMessage] + historyList + [Message(role: .user, content: text)]

        // 確認內容總字數是否大於最大tokens數量
        if messages.contentCount > (4000 * 4) {
            _ = historyList.dropFirst()
            messages = generateMessages(from: text)
        }
        return messages
    }

    private func appendToHistoryList(userText: String, responseText: String) {
        historyList.append(.init(role: .user, content: userText))
        historyList.append(.init(role: .assistant, content: responseText))
    }
}

extension OpenAIManager {
    // 發出提問請求(以串流方式回應)
    func sendMessageStream(text: String) async throws -> AsyncThrowingStream<String, Error> {
        var urlRequest = self.urlRequest
        urlRequest.httpBody = try jsonBody(text: text)
        
        let (result, response) = try await urlSession.bytes(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw "Invalid response"
        }

        guard 200...299 ~= httpResponse.statusCode else {
            var errorMessage = "Bad Response: \(httpResponse.statusCode)"
            var error = ""
            for try await line in result.lines {
                error.append(line)
            }
            if let errorData = error.data(using: .utf8), let errorReponse = try? jsonDecoder.decode(ErrorRootResponse.self, from: errorData).error {
                errorMessage.append(",\n\(errorReponse.message)")
            }
            throw errorMessage
        }

        return AsyncThrowingStream<String, Error> { continuation in
            Task(priority: .userInitiated) { [weak self] in
                guard let self = self else { return }
                do {
                    var streamText = ""
                    for try await line in result.lines {
                        if line.hasPrefix("data: "),
                           let data = line.dropFirst(6).data(using: .utf8),
                           let response = try? self.jsonDecoder.decode(StreamCompletionResponse.self, from: data),
                           let content = response.choices.first?.delta.content {
                            streamText += content
                            continuation.yield(content)
                        }
                    }
                    self.appendToHistoryList(userText: text, responseText: streamText)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // 發出提問請求(以完整訊息回應)
//    func sendMessage(_ text: String) async throws -> String {
//        var urlRequest = self.urlRequest
//        urlRequest.httpBody = try jsonBody(text: text, stream: false)
//        
//        let (data, response) = try await urlSession.data(for: urlRequest)
//
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw "Invalid response"
//        }
//
//        guard 200...299 ~= httpResponse.statusCode else {
//            var error = "Bad Response: \(httpResponse.statusCode)"
//            if let errorResposne = try? jsonDecoder.decode(ErrorRootResponse.self, from: data).error {
//                error.append(",\n \(errorResposne.message)")
//            }
//            throw error
//        }
//
//        do {
//            let completionResponse = try self.jsonDecoder.decode(CompletionResponse.self, from: data)
//            let responseText = completionResponse.choices.first?.message.content ?? ""
//            self.appendToHistoryList(userText: text, responseText: responseText)
//            return responseText
//        } catch {
//            throw error
//        }
//    }
    
}
