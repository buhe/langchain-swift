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
/*
 Enroll baidu cloud, and access https://console.bce.baidu.com/iam/#/iam/accesslist Get
 BAIDU_OCR_AK=xxx
 BAIDU_OCR_SK=xxx
 */
public class ImageOCRLoader: BaseLoader {
    let image: Data
    
    public init(image: Data, callbacks: [BaseCallbackHandler] = []) {
        self.image = image
        super.init(callbacks: callbacks)
    }
    
    public override func _load() async throws -> [Document] {
        let eventLoopGroup = ThreadManager.thread
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        defer {
            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
            try? httpClient.syncShutdown()
        }
        var text = ""
        let env = Env.loadEnv()
        if let ak = env["BAIDU_OCR_AK"],
           let sk = env["BAIDU_OCR_SK"]{
            let ocr = await BaiduClient.ocrImage(ak: ak, sk: sk, httpClient: httpClient, image: image)
            if ocr!["error_msg"].string != nil {
                throw LangChainError.LoaderError(ocr!["error_msg"].stringValue)
            } else {
                let words = ocr!["words_result"].arrayValue.map{$0["words"].stringValue}
                text = words.joined(separator: " ")
                return [Document(page_content: text, metadata: [:])]
            }
        } else {
            return []
        }
    }
    
    override func type() -> String {
        "BaiduOCR"
    }
}
