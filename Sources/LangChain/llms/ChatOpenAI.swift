//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/31.
//

import Foundation
import NIOPosix
import AsyncHTTPClient
import OpenAIKit

public struct ChatOpenAI {
    let temperature: Double
    let model: ModelID
    
    public init(temperature: Double = 0.0, model: ModelID = Model.GPT3.gpt3_5Turbo) {
        self.temperature = temperature
        self.model = model
    }
    public func straem(text: String, httpClient: HTTPClient) async -> AsyncThrowingStream<ChatStream, Error>? {
       
        let env = loadEnv()
        
        if let apiKey = env["OPENAI_API_KEY"] {
            let baseUrl = env["OPENAI_API_BASE"] ?? "api.openai.com"

            let configuration = Configuration(apiKey: apiKey, api: API(scheme: .https, host: baseUrl))

            let openAIClient = OpenAIKit.Client(httpClient: httpClient, configuration: configuration)
          
            let buffer = try! await openAIClient.chats.stream(model: model, messages: [.user(content: text)], temperature: temperature)
            return buffer
        } else {
            print("Please set openai api key.")
            return nil
        }
    }
}
