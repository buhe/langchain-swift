//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/7/27.
//
import AsyncHTTPClient
import Foundation
import NIOPosix
import SwiftyJSON

struct InferenceRequest: Encodable {
    let options = ["wait_for_model": true]
    let inputs: String
}

struct HFInferenceApi {
    let repo: String
    let task: String
    
    func inference(text: String) async throws -> JSON {
        let env = Env.loadEnv()
        let eventLoopGroup = ThreadManager.thread
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        defer {
            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
            try? httpClient.syncShutdown()
        }
        var request = HTTPClientRequest(url: "https://api-inference.huggingface.co/pipeline/\(task)/\(repo)")
        request.method = .POST
        request.headers.add(name: "Authorization", value: "Bearer \(env["HF_API_KEY"]!)")
        request.headers.add(name: "Content-Type", value: "application/json")
        let requestBody = try! JSONEncoder().encode(InferenceRequest(inputs: text))
        request.body = .bytes(requestBody)
        let response = try await httpClient.execute(request, timeout: .seconds(30))
        if response.status == .ok {
            let str = String(buffer: try await response.body.collect(upTo: 1024 * 1024))
            return try JSON(data: str.data(using: .utf8)!)
        } else {
            // handle remote error
            print("http code is not 200.")
            return "Bad requset."
        }
    }
}
