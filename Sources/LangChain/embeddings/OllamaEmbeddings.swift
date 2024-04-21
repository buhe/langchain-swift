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
        let embeddingRequest = EmbeddingRequest(model: model, prompt: text)
        guard let data = try await sendJSON(request: embeddingRequest, endpoint: "embeddings") else {
            return []
        }
        let apiResponse = try JSONDecoder().decode(Embedding.self, from: data)
        return apiResponse.embedding
    }
}
