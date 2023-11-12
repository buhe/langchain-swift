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
struct LlamaRequest: Encodable {

}


struct LlamaAPIWrapper {
    
    func tts(text: String, key: String, base: String) async -> Data? {
        let eventLoopGroup = ThreadManager.thread
        
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        defer {
            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
            try? httpClient.syncShutdown()
        }
        do {
            var request = HTTPClientRequest(url: "https://\(base)/v1/audio/speech")
            request.method = .POST
            request.headers.add(name: "Authorization", value: "Bearer \(key)")
            request.headers.add(name: "Content-Type", value: "application/json")
            let requestBody = try! JSONEncoder().encode(LlamaRequest())
            request.body = .bytes(requestBody)

            let response = try await httpClient.execute(request, timeout: .seconds(30))
            if response.status == .ok {
                return Data(buffer: try await response.body.collect(upTo: 1024 * 10240))
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
