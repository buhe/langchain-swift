//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/3.
//

import AsyncHTTPClient
import Foundation
import SWXMLHash
import NIOPosix

struct PubmedPage {
    let uid: String
    let webenv: String
    
    func content() async throws -> String {
        let eventLoopGroup = ThreadManager.thread
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        defer {
            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
            try? httpClient.syncShutdown()
        }
        
        let baseURL = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi"
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "db", value: "pubmed"),
            URLQueryItem(name: "retmode", value: "xml"),
            URLQueryItem(name: "id", value: self.uid),
            URLQueryItem(name: "webenv", value: self.webenv),
        ]
        print(components.url!.absoluteString)
        var request = HTTPClientRequest(url: components.url!.absoluteString)
        request.method = .GET
        
        let response = try await httpClient.execute(request, timeout: .seconds(30))
        if response.status == .ok {
            let str = String(buffer: try await response.body.collect(upTo: 1024 * 1024))
            let xml = XMLHash.parse(str.data(using: .utf8)!)
            var ar = xml["PubmedArticleSet"]["PubmedArticle"]["MedlineCitation"][
                "Article"
            ]
            if ar.element == nil {
                ar = xml["PubmedArticleSet"]["PubmedBookArticle"]["BookDocument"]
            }
            let summarys = ar["Abstract"]["AbstractText"].all
            let summarysStr = summarys.map{$0.element?.text}
            if !summarysStr.isEmpty && summarysStr.first != nil {
                return summarysStr.map{$0!}.joined(separator: "\n")
            } else {
                return ""
            }
        } else {
            // handle remote error
            print("http code is not 200.")
            return ""
        }
    }
}
