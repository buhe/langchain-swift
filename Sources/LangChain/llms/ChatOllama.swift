//
//  ChatOllama.swift
//
//  Created by Rene Hexel on 21/4/2024.
//

import Foundation
import OpenAIKit

/// Ollama class for chat functionality.
///
/// This class interfaces with the Ollama chat API.
public class ChatOllama: Ollama {
    /// The chat history.
    ///
    /// This array contains the chat history
    /// of the conversation so far.
    public var history = [ChatGLMMessage]()

    /// Create a new Ollama chat instance.
    ///
    /// This initialiser creates a new Ollama chat instance with the given parameters.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for the Ollama API.
    ///   - model: The model to use for the chat instance.
    ///   - options: Additional options for the chat instance.
    ///   - timeout: The request timeout in seconds.
    ///   - callbacks: The callback handlers to use.
    ///   - cache: The cache to use.
    public override init(baseURL: String? = nil, model: String? = nil, options: [String : String]? = nil, timeout: Int = 3600, callbacks: [BaseCallbackHandler] = [], cache: BaseCache? = nil) {
        super.init(baseURL: baseURL, model: model, options: options, timeout: timeout, callbacks: callbacks, cache: cache)
    }

    /// Send a text to the Ollama API.
    ///
    /// This function implements the main interaction with the Ollama API
    /// through its `chat` API.
    ///
    /// - Parameters:
    ///   - text: The text to send to the Ollama API.
    ///   - stops: An array of strings that, if present in the response, will stop the generation.
    /// - Returns:
    public override func _send(text: String, stops: [String] = []) async throws -> LLMResult {
        let message = ChatGLMMessage(role: "user", content: text)
        history.append(message)
        let chatRequest = ChatRequest(model: model, options: modelOptions, format: "json", stream: false, messages: history)
        guard let data = try await sendJSON(request: chatRequest, endpoint: "chat") else {
            return LLMResult()
        }
        let llmResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
        history.append(llmResponse.message)
        return LLMResult(llm_output: llmResponse.message.content)
    }
}

public extension ChatOllama {
    /// Generate the next message in a chat with a provided model.
    ///
    /// This is a streaming endpoint, so there can be a series of responses.
    /// Streaming can be disabled using "stream": false.
    struct ChatRequest: Codable, Sendable {
        public let model: String
        public let options: [String: String]?
        public let format: String
        public let stream: Bool
        public let messages: [ChatGLMMessage]
    }
    /// Ollama response to a `ChatRequest`.
    ///
    /// This response object includes the next message in a chat conversation.
    /// The final response object will include statistics and additional data from the request.
    struct ChatResponse: Codable, Sendable {
        public let message: ChatGLMMessage
        public let model: String
        public let done: Bool
        public let totalDuration: Int?
        public let loadDuration: Int?
        public let promptEvalDuration: Int?
        public let evalDuration: Int?
        public let promptEvalCount: Int?
        public let evalCount: Int?

        /// Return the message content.
        public var content: String { message.content }

        /// JSON coding keys for the `ChatResponse` struct.
        enum CodingKeys: String, CodingKey {
            case message
            case model
            case done
            case totalDuration = "total_duration"
            case loadDuration = "load_duration"
            case promptEvalDuration = "prompt_eval_duration"
            case evalDuration = "eval_duration"
            case promptEvalCount = "prompt_eval_count"
            case evalCount = "eval_count"
        }
    }
}
