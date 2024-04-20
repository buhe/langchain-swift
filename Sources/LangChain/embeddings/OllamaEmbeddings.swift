//
//  OllamaEmbeddings.swift
//
//  Created by Rene Hexel on 20/4/2024.
//
import Foundation
import AsyncHTTPClient

extension Ollama: Embeddings {
    /// Ollama embedding request.
    struct EmbeddingRequest: Codable {
        let model: String
        let prompt: String
    }
    /// Ollama embedding structure.
    struct Embedding: Codable {
        let embedding: [Float]
    }
    /// Create embeddings for a given text.
    ///
    /// This function sends a text to the Ollama API and returns the resulting embeddings.
    ///
    /// - Parameter text: The text to create embeddings for.
    /// - Returns: An array of embeddings for the given text.
    public func embedQuery(text: String) async -> [Float] {
        do {
            return try await getEmbeddings(for: text)
        } catch {
            return []
        }
    }
    /// Get the embeddings vector for a given text.
    ///
    /// This function sends a text to the Ollama API and returns the resulting embeddings.
    ///
    /// - Parameter text: The text to create embeddings vector for.
    /// - Returns: An array of embeddings for the given text.
    public func getEmbeddings(for text: String) async throws -> [Float] {
        let httpClient = getHTTPClient()
        defer {
            try? httpClient.syncShutdown()
        }
        let requestURL = "http://\(baseURL)/api/embeddings"
        var request = HTTPClientRequest(url: requestURL)
        request.method = .POST
        request.headers.add(name: "Content-Type", value: "application/json")
        request.headers.add(name: "Accept", value: "application/json")
        let embeddingRequest = EmbeddingRequest(model: model, prompt: text)
        let requestBody = try JSONEncoder().encode(embeddingRequest)
        request.body = .bytes(requestBody)
        let response = try await httpClient.execute(request, timeout: .seconds(Int64(requestTimeout)))
        guard response.status == .ok else {
            return []
        }
        let data = Data(buffer: try await response.body.collect(upTo: 2048 * 1024))
        let apiResponse = try JSONDecoder().decode(Embedding.self, from: data)
        return apiResponse.embedding
    }
}
