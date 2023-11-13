//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/2.
//
import AsyncHTTPClient
import Foundation
import SwiftyJSON
import NIOPosix
import OpenAIKit

struct LlamaRequest: Encodable {
    let temperature: Double
    let max_tokens: Int
    let topP: Double
    let n: Int
    let stops: [String]
    let messages: [Chat.Message]
}


struct LlamaAPIWrapper {
    
    func execute(text: String, key: String, temperature: Double, max_tokens: Int, topP: Double, n: Int, stops: [String] = []) async -> String? {
        let eventLoopGroup = ThreadManager.thread
        
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        defer {
            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
            try? httpClient.syncShutdown()
        }
        do {
            var request = HTTPClientRequest(url: "https://api.llama-api.com/chat/completions")
            request.method = .POST
            request.headers.add(name: "Authorization", value: "Bearer \(key)")
            request.headers.add(name: "Content-Type", value: "application/json")
            let requestBody = try! JSONEncoder().encode(LlamaRequest(temperature: temperature, max_tokens: max_tokens, topP: topP, n: n, stops: stops, messages: [.user(content: text)]))
            request.body = .bytes(requestBody)

            let response = try await httpClient.execute(request, timeout: .seconds(30))
            if response.status == .ok {
                let str = String(buffer: try await response.body.collect(upTo: 1024 * 1024))
//                print(str)
                let json = try JSON(data: str.data(using: .utf8)!)
                return json["choices"].arrayValue[0]["message"]["content"].stringValue
            } else {
                // handle remote error
                print("http code is not 200.")
                return nil
            }
        } catch {
            // handle error
            print(error.localizedDescription)
            return nil
        }
    }
}
