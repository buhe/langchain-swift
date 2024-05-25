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

    public let baseURL: String
    public let model: String
    public let options: [String: String]?
    public let requestTimeout: Int

    /// Images encoded as base64 strings.
    public var images: [String]?
    /// A system prompt overriding the default system prompt.
    public var systemPrompt: String?
    /// The template to use (overriding what is in the model file).
    public var template: String?
    /// The context to use.
    ///
    /// The context parameter returned from a previous request to `/generate`,
    /// this can be used to keep a short conversational memory.
    public var context: [Int]?
    /// Request streaming content.
    ///
    /// This acts as a flag to the API whether to use
    /// streaming or not.  If set to `false`, the API
    /// will return a single response object rather than
    /// a stream of responses.
    public var stream = false
    /// Use raw content.
    ///
    /// If set to `true`, this indicates to the API that
    /// no formatting has been applied to the input prompt.
    /// You may choose to use the raw parameter if you are
    /// providing a full templated prompt in your request.
    public var raw: Bool?
    /// Model options to use.
    ///
    /// Dictionary of additional model parameters listed in the
    /// documentation for the Modelfile such as `temperature`.
    public var modelOptions: [String: String]?
    /// Keep-alive time for the model.
    ///
    /// If set, this will keep the model alive for the given
    /// amount of time after the last request, overriding
    /// the Ollama default.
    public var keepAliveTime: String?

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
        let urlString = baseURL ?? env["OLLAMA_URL"] ?? "localhost:11434"
        let url: String
        if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
            url = urlString
        } else {
            url = "http://" + urlString
        }
        self.baseURL = url
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
        let apiRequest = GenerateRequest(model: model, prompt: text, images: images, system: systemPrompt, template: template, context: context, options: modelOptions, keepAlive: keepAliveTime, format: "json", raw: self.raw, stream: false)
        guard let data = try await sendJSON(request: apiRequest) else {
            return LLMResult()
        }
        let llmResponse = try JSONDecoder().decode(GenerateResponse.self, from: data)
        context = llmResponse.context
        return LLMResult(llm_output: llmResponse.response)
    }

    /// Send a request to the Ollama API.
    ///
    /// This function implements the main interaction with the Ollama
    /// through API.
    ///
    /// - Parameters:
    ///   - request: The request to send to the Ollama API.
    ///   - endpoint: The API endpoint to use.
    /// - Returns: The response data from the Ollama API (or `nil` if unsuccessful).
    public func sendJSON<Request: Encodable>(request: Request?, endpoint: String = "generate") async throws -> Data? {
        let httpClient = getHTTPClient()
        defer {
            try? httpClient.syncShutdown()
        }
        let requestURL = baseURL + "/api/" + endpoint
        var http = HTTPClientRequest(url: requestURL)
        http.headers.add(name: "Content-Type", value: "application/json")
        http.headers.add(name: "Accept", value: "application/json")
        if let request {
            let requestBody = try JSONEncoder().encode(request)
            http.body = .bytes(requestBody)
            http.method = .POST
        }
        let response = try await httpClient.execute(http, timeout: .seconds(Int64(requestTimeout)))
        guard response.status == .ok else {
            print("http code is not 200.")
            return nil
        }
        let data = Data(buffer: try await response.body.collect(upTo: 2048 * 1024))
        return data
    }

    /// Send a query to the given endpoint.
    ///
    /// This function sends a query (a request without a body)
    /// to the given endpoint and returns the response as `Data`.
    ///
    /// - Parameter endpoint: The endpoint to send the query to.
    /// - Returns: The response data from the Ollama API (or `nil` if unsuccessful).
    @inlinable
    public func sendQuery(endpoint: String = "tags") async throws -> Data? {
        try await sendJSON(request: Optional<Bool>.none, endpoint: endpoint)
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
    /// Ollama generation request.
    ///
    /// This message is sent to the `generate` API
    /// endpoint to generate a response.
    struct GenerateRequest: Codable {
        public let model: String
        public let prompt: String
        public let images: [String]?
        public let system: String?
        public let template: String?
        public let context: [Int]?
        public let options: [String: String]?
        public let keepAlive: String?
        public let format: String?
        public let raw: Bool?
        public let stream: Bool?

        enum CodingKeys: String, CodingKey {
            case model
            case prompt
            case images
            case system
            case template
            case context
            case options
            case keepAlive = "keep_alive"
            case format
            case raw
            case stream
        }

        /// Create a new `GenerateRequest`.
        ///
        /// This initializer creates a new `GenerateRequest`.
        ///
        /// - Parameters:
        ///  - model: The model to use for generation.
        ///  - prompt: The prompt to use for generation.
        ///  - images: An array of images to use for generation.
        ///  - system: The system prompt to use for generation.
        ///  - template: The template to use for generation.
        ///  - context: The context to use for generation.
        ///  - options: The options to use for generation.
        ///  - keepAlive: The keep-alive time for the generation.
        ///  - format: The format to use for the response.
        ///  - raw: Whether to return the raw response.
        ///  - stream: Whether to stream the response.
        /// - Returns: A new `GenerateRequest`.
        @inlinable
        public init(model: String, prompt: String, images: [String]? = nil, system: String? = nil, template: String? = nil, context: [Int]? = nil, options: [String: String]? = nil, keepAlive: String? = nil, format: String? = nil, raw: Bool? = nil, stream: Bool? = nil) {
            self.model = model
            self.prompt = prompt
            self.images = images
            self.system = system
            self.template = template
            self.context = context
            self.options = options
            self.keepAlive = keepAlive
            self.format = format
            self.raw = raw
            self.stream = stream
        }
    }
    /// Ollama generation response.
    ///
    /// This response object contains the response
    /// generated by the Ollama `generate` API endpoint.
    struct GenerateResponse: Codable {
        public let response: String
        public let createdAt: String
        public let model: String
        public let done: Bool
        public let context: [Int]?
        public let totalDuration: Int?
        public let loadDuration: Int?
        public let promptEvalDuration: Int?
        public let evalDuration: Int?
        public let promptEvalCount: Int?
        public let evalCount: Int?

        enum CodingKeys: String, CodingKey {
            case response
            case createdAt = "created_at"
            case model
            case done
            case context
            case totalDuration = "total_duration"
            case loadDuration = "load_duration"
            case promptEvalDuration = "prompt_eval_duration"
            case evalDuration = "eval_duration"
            case promptEvalCount = "prompt_eval_count"
            case evalCount = "eval_count"
        }

        /// Create a new `GenerateResponse`.
        ///
        /// This initializer creates a new `GenerateResponse`.
        ///
        /// - Parameters:
        ///  - response: The generated response string.
        ///  - createdAt: The creation time of the response.
        ///  - model: The model used for generation.
        ///  - done: Whether generation is complete.
        ///  - context: The context used for generation.
        ///  - totalDuration: The total duration of the generation.
        ///  - loadDuration: The load duration of the generation.
        ///  - promptEvalDuration: The duration of the prompt evaluation.
        ///  - evalDuration: The duration of the evaluation.
        ///  - promptEvalCount: The prompt evaluation count.
        ///  - evalCount: The evaluation count.
        /// - Returns: A new `GenerateResponse`.
        @inlinable
        public init(response: String, createdAt: String, model: String, done: Bool, context: [Int]? = nil, totalDuration: Int? = nil, loadDuration: Int? = nil, promptEvalDuration: Int? = nil, evalDuration: Int? = nil, promptEvalCount: Int? = nil, evalCount: Int? = nil) {
            self.response = response
            self.createdAt = createdAt
            self.model = model
            self.done = done
            self.context = context
            self.totalDuration = totalDuration
            self.loadDuration = loadDuration
            self.promptEvalDuration = promptEvalDuration
            self.evalDuration = evalDuration
            self.promptEvalCount = promptEvalCount
            self.evalCount = evalCount
        }
    }
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
        /// Ollama model details.
        public let name: String
        /// The last modification date of the model.
        public let modifiedAt: String
        /// The digest of the model.
        public let digest: String
        /// The size of the model.
        public let size: Int
        /// The details of the model.
        public let details: ModelDetails

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
        /// The format of the model.
        public let format: String
        /// The family of the model.
        public let family: String
        /// The families of the model.
        public let families: [String]?
        /// The size of the model parameters.
        public let parameterSize: String
        /// The quantization level of the model.
        public let quantizationLevel: String

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
        guard let data = try await sendQuery(endpoint: "tags") else {
            return []
        }
        let local = try JSONDecoder().decode(Models.self, from: data)
        return local.models
    }
}
