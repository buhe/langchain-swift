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
struct OpenAITTSRequest: Encodable {
    let model: String
    let input: String
    let voice: String
    let response_format: String
    let speed: String
}
enum Voice: String, Encodable {
    case alloy
    case echo
    case fable
    case onyx
    case nova
    case shimmer
}
enum TTSModel: String, Encodable{
    case tts1hd = "tts-1-hd"
    case tts1 = "tts-1"
}
enum TTSFormat: String {
    case mp3
    case opus
    case aac
    case flac
}
struct OpenAITTSAPIWrapper {
    
    func tts(voice: Voice = .alloy, model: TTSModel = .tts1, format: TTSFormat = .mp3, speed: String = "1.0", text: String, key: String, base: String) async -> Data? {
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
            let requestBody = try! JSONEncoder().encode(OpenAITTSRequest(model: model.rawValue, input: text, voice: voice.rawValue, response_format: format.rawValue, speed: speed))
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
