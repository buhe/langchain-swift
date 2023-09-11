//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/9/4.
//

import Foundation
import NIOPosix
import AsyncHTTPClient
// Create ai app on https://console.bce.baidu.com/qianfan/ais/console/applicationConsole/application
// And get app ak sk
public class Baidu: LLM {
    let temperature: Double
    
    public init(temperature: Double = 0.8) {
        self.temperature = temperature
    }
    
    public override func _send(text: String, stops: [String] = []) async throws -> LLMResult {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        defer {
            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
            try? httpClient.syncShutdown()
        }
        let env = Env.loadEnv()
        if let ak = env["BAIDU_LLM_AK"],
           let sk = env["BAIDU_LLM_SK"]{
            return LLMResult(llm_output: try await BaiduClient.llmSync(ak: ak, sk: sk, httpClient: httpClient, text: text, temperature: temperature))
        } else {
            print("Please set baidu llm ak sk.")
            return LLMResult(llm_output: "Please set baidu llm ak sk.")
        }
    }
    
}
