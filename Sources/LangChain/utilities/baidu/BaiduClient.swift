//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/5.
//

import AsyncHTTPClient
import Foundation
import SwiftyJSON
//import UIKit

struct BaiduLLMRequest: Codable {
    let temperature: Double
    let messages: [ChatGLMMessage]
}

struct BaiduLLMResponse: Codable {
    let usage: ChatGLMResponseDataUsage
    let result: String
    let object: String
    let created: Int
    let need_clear_history: Bool
}

public struct BaiduClient {
    
    static func llmSync(ak: String, sk: String, httpClient: HTTPClient, text: String, temperature: Double) async throws -> String? {
        if let accessToken = await getAccessToken(ak: ak, sk: sk, httpClient: httpClient) {
            let url = "https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/completions?access_token=" + accessToken
            
            var request = HTTPClientRequest(url: url)
            request.method = .POST
            request.headers.add(name: "Content-Type", value: "application/json")
            request.headers.add(name: "Accept", value: "application/json")
            let requestBody = try! JSONEncoder().encode(BaiduLLMRequest(temperature: temperature, messages: [ChatGLMMessage(role: "user", content: text)]))
            request.body = .bytes(requestBody)
            let response = try await httpClient.execute(request, timeout: .seconds(30))
            if response.status == .ok {
                let str = String(buffer: try await response.body.collect(upTo: 1024 * 1024))
                let data = str.data(using: .utf8)!
                let llmResponse = try! JSONDecoder().decode(BaiduLLMResponse.self, from: data)
                return llmResponse.result
            } else {
                // handle remote error
                print("http code is not 200.")
                return nil
            }
        
        }
        return nil
    }
    static func ocrImage(ak: String, sk: String, httpClient: HTTPClient, image: Data) async -> JSON? {
        if let accessToken = await getAccessToken(ak: ak, sk: sk, httpClient: httpClient) {
            let url = "https://aip.baidubce.com/rest/2.0/ocr/v1/webimage_loc?access_token=" + accessToken
            
            do {
                var request = HTTPClientRequest(url: url)
                request.method = .POST
                request.headers.add(name: "Content-Type", value: "application/x-www-form-urlencoded")
                request.headers.add(name: "Accept", value: "application/json")
                var requestBodyComponents = URLComponents()
                var b64 = image.base64EncodedString()
                b64 = b64.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
                requestBodyComponents.queryItems = [URLQueryItem(name: "image", value: b64)]
                request.body = .bytes((requestBodyComponents.query?.data(using: .utf8)!)!)
                
                let response = try await httpClient.execute(request, timeout: .seconds(30))
                if response.status == .ok {
//                    let expectedBytes = response.headers.first(name: "content-length").flatMap(Int.init)
                    let str = String(buffer: try await response.body.collect(upTo: 1024 * 1024))
                    return try JSON(data: str.data(using: .utf8)!)
                } else {
                    // handle remote error
                    print("http code is not 200.")
                    return nil
                }
            } catch {
                // handle error
                print(error)
                return nil
            }
        }
        return ""
    }
    static func getAccessToken(ak: String,sk: String, httpClient: HTTPClient) async -> String? {
        let url = "https://aip.baidubce.com/oauth/2.0/token"
        var component = URLComponents(string: url)!
        component.queryItems = []
//        let params = ["grant_type": "client_credentials", "client_id": ak, "client_secret": sk]
        component.queryItems?.append(URLQueryItem(name: "grant_type", value: "client_credentials"))
        component.queryItems?.append(URLQueryItem(name: "client_id", value: ak))
        component.queryItems?.append(URLQueryItem(name: "client_secret", value: sk))
        do {
            var request = HTTPClientRequest(url: component.url!.absoluteString)
            request.method = .GET
            let response = try await httpClient.execute(request, timeout: .seconds(30))
            if response.status == .ok {
                let result = String(buffer: try await response.body.collect(upTo: 1024 * 1024))
                return try JSON(data: result.data(using: .utf8)!)["access_token"].stringValue
            } else {
                // handle remote error
                print("http code is not 200.")
                return nil
            }
        } catch {
            // handle error
            print(error)
            return nil
        }
            
    }
}
