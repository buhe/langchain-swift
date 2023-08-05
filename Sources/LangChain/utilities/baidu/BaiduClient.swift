//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/5.
//

import AsyncHTTPClient
import Foundation
import NIOPosix
import SwiftyJSON

public struct BaiduClient {
    
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
