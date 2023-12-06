//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/12.
//

import Foundation
import NIOPosix
import AsyncHTTPClient
import OpenAIKit

public struct OpenAIEmbeddings: Embeddings {
    public init() {
        
    }
    
//    public func embedDocuments(texts: [String]) -> [[Float]] {
//        []
//    }
    
    public func embedQuery(text: String) async -> [Float] {
        let eventLoopGroup = ThreadManager.thread
       
        let env = Env.loadEnv()
        
        if let apiKey = env["OPENAI_API_KEY"] {
            let baseUrl = env["OPENAI_API_BASE"] ?? "api.openai.com"
            
            let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
            let configuration = Configuration(apiKey: apiKey, api: API(scheme: .https, host: baseUrl))

            let openAIClient = OpenAIKit.Client(httpClient: httpClient, configuration: configuration)
            defer {
                // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
                try? httpClient.syncShutdown()
            }
            do {
                let embedding = try await openAIClient.embeddings.create(input: text)
                
                //            print(embedding.data[0].embedding)
                return embedding.data[0].embedding
            } catch {
                return []
            }
        } else {
            print("Please set openai api key.")
            return []
        }

        
    }
    
    
}
