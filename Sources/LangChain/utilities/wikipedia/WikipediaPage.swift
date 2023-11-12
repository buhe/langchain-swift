//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/3.
//

import AsyncHTTPClient
import Foundation
import SwiftyJSON
import NIOPosix

struct WikipediaPage {
    let title: String
    let pageid: Int
    
    func content() async throws -> String {
        let eventLoopGroup = ThreadManager.thread
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        defer {
            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
            try? httpClient.syncShutdown()
        }
        
        let baseURL = "http://en.wikipedia.org/w/api.php"
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "prop", value: "extracts|revisions"),
            URLQueryItem(name: "rvprop", value: "ids"),
            URLQueryItem(name: "titles", value: self.title),
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "format", value: "json"),
        ]
//        print(components.url!.absoluteString)
        var request = HTTPClientRequest(url: components.url!.absoluteString)
        request.method = .GET
        
        let response = try await httpClient.execute(request, timeout: .seconds(30))
        if response.status == .ok {
            let str = String(buffer: try await response.body.collect(upTo: 1024 * 1024))
//            print(str)
            let json = try JSON(data: str.data(using: .utf8)!)
            return json["query"]["pages"]["\(self.pageid)"]["extract"].stringValue
            
        } else {
            // handle remote error
            print("http code is not 200.")
            return ""
        }
    }
}
