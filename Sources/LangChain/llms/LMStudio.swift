//
//  File.swift
//  
//
//  Created by 顾艳华 on 1/17/24.
//

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
//{
// "id": "chatcmpl-8wiceqlk0jhyverlvd028",
// "object": "chat.completion",
// "created": 1705470413,
// "model": "/Users/guyanhua/.cache/lm-studio/models/TheBloke/Mythalion-13B-GGUF/mythalion-13b.Q4_0.gguf",
// "choices": [
//   {
//     "index": 0,
//     "message": {
//       "role": "assistant",
//       "content": " Hello!"
//     },
//     "finish_reason": "stop"
//   }
// ],
// "usage": {
//   "prompt_tokens": 13,
//   "completion_tokens": 2,
//   "total_tokens": 15
// }
//}
struct LMStudioResponceChoices: Codable {
    let index: Int
    let message: ChatGLMMessage
}
struct LMStudioResponce: Codable {
    let choices: [LMStudioResponceChoices]
}
public class LMStudio: LLM {
    
    let temperature: Double
    
    public init(temperature: Double = 0.0, callbacks: [BaseCallbackHandler] = [], cache: BaseCache? = nil) {
        self.temperature = temperature
        super.init(callbacks: callbacks, cache: cache)
    }
    
    public override func _send(text: String, stops: [String] = []) async throws -> LLMResult {
        let env = Env.loadEnv()
        let baseUrl = env["LMSTUDIO_URL"] ?? "localhost:1234"
        let eventLoopGroup = ThreadManager.thread

        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        defer {
            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
            try? httpClient.syncShutdown()
        }
        let url = "http://\(baseUrl)/v1/chat/completions"
        var request = HTTPClientRequest(url: url)
        request.method = .POST
        request.headers.add(name: "Content-Type", value: "application/json")
        request.headers.add(name: "Accept", value: "application/json")
        let requestBody = try! JSONEncoder().encode(BaiduLLMRequest(temperature: temperature, messages: [ChatGLMMessage(role: "user", content: text)]))
        request.body = .bytes(requestBody)
        let response = try await httpClient.execute(request, timeout: .seconds(1800))
        if response.status == .ok {
            let str = String(buffer: try await response.body.collect(upTo: 1024 * 1024))
            let data = str.data(using: .utf8)!
            let llmResponse = try! JSONDecoder().decode(LMStudioResponce.self, from: data)
            return LLMResult(llm_output: llmResponse.choices.first!.message.content)
        } else {
            // handle remote error
            print("http code is not 200.")
            return LLMResult()
        }
    }
    
    
}
