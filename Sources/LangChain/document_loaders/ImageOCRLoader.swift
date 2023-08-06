//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/5.
//

import Foundation
//import UIKit
import AsyncHTTPClient
import NIOPosix

public struct ImageOCRLoader: BaseLoader {
    let image: Data
    
    public init(image: Data) {
        self.image = image
    }
    
    public func load() async -> [Document] {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        defer {
            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
            try? httpClient.syncShutdown()
        }
        var text = ""
        let env = loadEnv()
        if let ak = env["BAIDU_AK"],
           let sk = env["BAIDU_SK"]{
            let ocr = await BaiduClient.ocrImage(ak: ak, sk: sk, httpClient: httpClient, image: image)
            let words = ocr!["words_result"].arrayValue.map{$0["words"].stringValue}
            text = words.joined(separator: " ")
            return [Document(page_content: text, metadata: [:])]
        } else {
            return []
        }
    }
    
    
}
