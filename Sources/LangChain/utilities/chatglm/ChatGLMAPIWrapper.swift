//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/29.
//

import AsyncHTTPClient
import Foundation
import NIOPosix

struct ChatGLMMessage: Codable {
    let role: String
    let content: String
}
struct ChatGLMPayload: Codable {
    let prompt: [ChatGLMMessage]
    let temperature: Double
}
struct ChatGLMResponseDataUsage: Codable {
    let prompt_tokens: Int?
    let completion_tokens: Int?
    let total_tokens: Int
}
struct ChatGLMResponseData: Codable {
    let request_id: String
    let task_id: String
    let task_status: String
    let choices: [ChatGLMMessage]
    let usage: ChatGLMResponseDataUsage
}
struct ChatGLMResponse: Codable {
    let code: Int
    let msg: String
    let success: Bool
    let data: ChatGLMResponseData?
}
struct ChatGLMAPIWrapper {
    let model: ChatGLMModel
    let temperature: Double
    
    init(model: ChatGLMModel, temperature: Double) {
        self.model = model
        self.temperature = temperature
    }
    private func jwt(secret: String, id: String) -> String {
        let jwt = JWT(secret: secret)
        jwt.header = ["sign_type": "SIGN", "alg": "HS256"]
        jwt.payload = ["api_key": id, "timestamp": Int(Date.now.timeIntervalSince1970), "exp": Int(Date.now.timeIntervalSince1970) + 3600]
        return jwt.token!
    }
    func call(text: String) async throws -> String {
        let env = Env.loadEnv()
        if let apiKey = env["CHATGLM_API_KEY"] {
            let splited = apiKey.components(separatedBy: ".")
            let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

            let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
            
            var request = HTTPClientRequest(url: String(format: "https://open.bigmodel.cn/api/paas/v3/model-api/%@/invoke",model.rawValue))
            request.method = .POST
            request.headers.add(name: "Content-Type", value: "application/json")
            request.headers.add(name: "Authorization", value: "Bearer " + jwt(secret: splited[1], id: splited[0]))
            let requestBody = try! JSONEncoder().encode(ChatGLMPayload(prompt: [ChatGLMMessage(role: "user", content: text)], temperature: 0.8))
            request.body = .bytes(requestBody)
            defer {
                // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
                try? httpClient.syncShutdown()
            }
            let response = try await httpClient.execute(request, timeout: .seconds(30))
            if response.status == .ok {
                let string = String(buffer: try await response.body.collect(upTo: 1024 * 1024))
                let reps = try! JSONDecoder().decode(ChatGLMResponse.self, from: string.data(using: .utf8)!)
                if let data = reps.data{
                    return data.choices.first!.content
                } else {
                    return reps.msg
                }
            } else {
                // handle remote error
                print("http code is not 200.")
                return "Bad requset."
            }
        } else {
            print("Please set chatglm api key.")
            return "Please set chatglm api key."
        }
    }
}
