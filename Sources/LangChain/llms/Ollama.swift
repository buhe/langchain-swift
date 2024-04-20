//
//  Ollama.swift
//
//  Created by Rene Hexel on 20/4/2024.
//

import Foundation
import NIOPosix
import AsyncHTTPClient
import OpenAIKit

/// Ollama language model.
///
/// This class is a wrapper around the Ollama API.
public class Ollama: LLM {

    let baseURL: String
    let model: String
    let options: [String: String]?
    let requestTimeout: Int


    /// Create an Ollama language model.
    ///
    /// This initialiser creates an Ollama language model binding,
    /// optionally specifying a base URL, model name, temperature,
    /// callback handlers, and a cache.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL to use for the Ollama API (defaults to the content of the `OLLAMA_URL` environment variable or `localhost:11434`).
    ///   - model: The model name to use (defaults to the content of the `OLLAMA_MODEL` environment variable or `llama3`).
    ///   - options: A dictionary of additional model parameters listed in the documentation for the Modelfile such as `temperature`.`
    ///   - timeout: The timeout to use for the request in seconds.
    ///   - callbacks: Array of callback handlers to use.
    ///   - cache: Cache to use for storing results.
    public init(baseURL: String? = nil, model: String? = nil, options: [String : String]? = nil, timeout: Int = 3600, callbacks: [BaseCallbackHandler] = [], cache: BaseCache? = nil) {
        let env = LC.loadEnv()
        self.baseURL = baseURL ?? env["OLLAMA_URL"] ?? "localhost:11434"
        self.model = model ?? env["OLLAMA_MODEL"] ?? "llama3"
        self.options = options
        self.requestTimeout = timeout
        super.init(callbacks: callbacks, cache: cache)
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
        let httpClient = getHTTPClient()
        defer {
            try? httpClient.syncShutdown()
        }
        let requestURL = "http://\(baseURL)/api/chat"
        var request = HTTPClientRequest(url: requestURL)
        request.method = .POST
        request.headers.add(name: "Content-Type", value: "application/json")
        request.headers.add(name: "Accept", value: "application/json")
        let chatRequest = ChatRequest(model: model, options: options, format: "json", stream: false, messages: [ChatGLMMessage(role: "user", content: text)])
        let requestBody = try JSONEncoder().encode(chatRequest)
        request.body = .bytes(requestBody)
        let response = try await httpClient.execute(request, timeout: .seconds(Int64(requestTimeout)))
        guard response.status == .ok else {
            print("http code is not 200.")
            return LLMResult()
        }
        let data = Data(buffer: try await response.body.collect(upTo: 2048 * 1024))
        let llmResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
        return LLMResult(llm_output: llmResponse.message.content)
    }

    /// Get an Ollama HTTP client.
    ///
    /// This function returns an HTTP client that can be used to send
    /// requests to the Ollama API.
    func getHTTPClient() -> HTTPClient {
        let eventLoopGroup = ThreadManager.thread
        return HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
    }
}

public extension Ollama {
    /// Generate the next message in a chat with a provided model.
    ///
    /// This is a streaming endpoint, so there can be a series of responses.
    /// Streaming can be disabled using "stream": false.
    struct ChatRequest: Codable {
        let model: String
        let options: [String: String]?
        let format: String
        let stream: Bool
        let messages: [ChatGLMMessage]
    }
    /// Ollama response to a `ChatRequest`.
    ///
    /// This response object includes the next message in a chat conversation.
    /// The final response object will include statistics and additional data from the request.
    struct ChatResponse: Codable {
        let message: ChatGLMMessage
        let model: String
        let done: Bool
        let totalDuration: Int?
        let loadDuration: Int?
        let promptEvalDuration: Int?
        let evalDuration: Int?
        let promptEvalCount: Int?
        let evalCount: Int?
        
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
    /// List of Ollama models.
    ///
    /// This struct represents a list of locally available models.
    struct Models: Codable {
        let models: [Model]
    }
    /// Ollama model.
    ///
    /// This struct represents a single Ollama model
    /// that is available via the API.
    struct Model: Codable {
        let name: String
        let modifiedAt: String
        let digest: String
        let size: Int
        let details: ModelDetails

        /// JSON coding keys for the `Model` struct.
        enum CodingKeys: String, CodingKey {
            case name
            case modifiedAt = "modified_at"
            case digest
            case size
            case details
        }
    }
    /// Ollama model details.
    ///
    /// This struct represents the details of an Ollama model.
    struct ModelDetails: Codable {
        let format: String
        let family: String
        let families: [String]?
        let parameterSize: String
        let quantizationLevel: String

        /// JSON coding keys for the `ModelDetails` struct.
        enum CodingKeys: String, CodingKey {
            case format
            case family
            case families
            case parameterSize = "parameter_size"
            case quantizationLevel = "quantization_level"
        }
    }
    /// Return the available models.
    /// 
    /// This function returns the list of models
    /// that are available locally.
    /// 
    /// - Returns: An array of model names.
    func localModels() async throws -> [Model] {
        let httpClient = getHTTPClient()
        defer {
            try? httpClient.syncShutdown()
        }
        let requestURL = "http://\(baseURL)/api/tags"
        let request = HTTPClientRequest(url: requestURL)
        let response = try await httpClient.execute(request, timeout: .seconds(Int64(requestTimeout)))
        guard response.status == .ok else {
            return []
        }
        let data = Data(buffer: try await response.body.collect(upTo: 1024 * 1024))
        let local = try JSONDecoder().decode(Models.self, from: data)
        return local.models
    }
}
