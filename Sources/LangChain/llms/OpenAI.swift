//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/10.
//

import Foundation
import NIOPosix
import AsyncHTTPClient
import OpenAIKit

public class OpenAI: LLM {
    
    let temperature: Double
    let model: ModelID
    
    public init(temperature: Double = 0.0, model: ModelID = Model.GPT3.gpt3_5Turbo, callbacks: [BaseCallbackHandler] = []) {
        self.temperature = temperature
        self.model = model
        super.init(callbacks: callbacks)
    }
    
    public override func _send(text: String, stops: [String] = []) async throws -> LLMResult {
        let env = Env.loadEnv()
        
        if let apiKey = env["OPENAI_API_KEY"] {
            let baseUrl = env["OPENAI_API_BASE"] ?? "api.openai.com"
            let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

            let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
            defer {
                // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
                try? httpClient.syncShutdown()
            }
            let configuration = Configuration(apiKey: apiKey, api: API(scheme: .https, host: baseUrl))

            let openAIClient = OpenAIKit.Client(httpClient: httpClient, configuration: configuration)
            
            let completion = try await openAIClient.chats.create(model: model, messages: [.user(content: text)], temperature: temperature, stops: stops)
            return LLMResult(llm_output: completion.choices.first!.message.content)
        } else {
            print("Please set openai api key.")
            return LLMResult(llm_output: "Please set openai api key.")
        }
        
    }
    
    
}
