//
//  ChatModel.swift
//  Kiwee
//
//  Created by NY on 2024/4/22.
//

import Foundation

// MARK: - Request
struct Request: Codable {
    let model: String
    let messages: [Message]
    let temperature: Double
    let stream: Bool
}

struct Message: Codable {
    let role: ChatGPTRole
    let content: String
    
    enum ChatGPTRole: String, Codable {
        case system
        case user
        case assistant
    }
}

// MARK: - Resposne
struct CompletionResponse: Decodable {
    let choices: [Choice]
}

struct Choice: Decodable {
    let message: Message
}

struct StreamCompletionResponse: Decodable {
    let choices: [StreamChoice]
}

struct StreamChoice: Decodable {
    let delta: StreamMessage
}

struct StreamMessage: Decodable {
    let role: String?
    let content: String?
}

// MARK: - Error
struct ErrorRootResponse: Decodable {
    let error: ErrorResponse
}
struct ErrorResponse: Decodable {
    let message: String
    let type: String?
}
