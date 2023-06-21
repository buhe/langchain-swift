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

public struct OpenAI: LLM {
    public init() {
        
    }
    public func send(text: String, stops: [String] = []) async -> String {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
       
        let env = loadEnv()
        
        if let apiKey = env["OPENAI_API_KEY"] {
            let baseUrl = env["OPENAI_API_BASE"] ?? "api.openai.com"

            let configuration = Configuration(apiKey: apiKey, api: API(scheme: .https, host: baseUrl))

            let openAIClient = OpenAIKit.Client(httpClient: httpClient, configuration: configuration)
            defer {
                // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
                try? httpClient.syncShutdown()
            }
            let completion = try! await openAIClient.chats.create(model: Model.GPT3.gpt3_5Turbo, messages: [.user(content: text)], temperature: 0, stops: stops)
            return completion.choices.first!.message.content
        } else {
            print("Please set openai api key.")
            return "Please set openai api key."
        }
        
    }
    
    
}
