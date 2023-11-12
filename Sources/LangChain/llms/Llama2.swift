//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/9/7.
//



// https://www.llama-api.com/account/api-token
import Foundation
import NIOPosix
import AsyncHTTPClient
import OpenAIKit

public class Llama2: LLM {
    
    let temperature: Double
    let model: ModelID
    
    public init(temperature: Double = 0.0, model: ModelID = Model.LLAMA2.llama13bchat) {
        self.temperature = temperature
        self.model = model
    }
    
    public override func _send(text: String, stops: [String] = []) async -> LLMResult {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
       
        let env = Env.loadEnv()
        
        if let apiKey = env["LLAMA2_API_KEY"] {

            let configuration = Configuration(apiKey: apiKey, api: API(scheme: .https, host: "api.llama-api.com"))

            let openAIClient = OpenAIKit.Client(httpClient: httpClient, configuration: configuration)
            defer {
                // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
                try? httpClient.syncShutdown()
            }
            let completion = try! await openAIClient.chats.create(model: model, messages: [.user(content: text)], temperature: temperature, stops: stops)
            return LLMResult(llm_output: completion.choices.first!.message.content)
        } else {
            print("Please set llama2 api key.")
            return LLMResult(llm_output: "Please set llama2 api key.")
        }
        
    }
    
    
}

extension Model {
    public enum LLAMA2: String, ModelID {
        case llama13bchat = "llama-13b-chat"
    }
}

