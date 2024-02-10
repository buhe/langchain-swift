//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/7/29.
//

import Foundation

public class BilibiliLoader: BaseLoader {
    let videoId: String
    
    public init(videoId: String, callbacks: [BaseCallbackHandler] = []) {
        self.videoId = videoId
        super.init(callbacks: callbacks)
    }
        
    public override func _load() async throws -> [Document] {
        let client = BilibiliClient(credential: BilibiliCredential(sessin: "7c987c09%2C1722322455%2Cd8f13%2A21CjB8GNfrlOnsm4mTTEv4_hK764LWdNRZprUKH0iHdXdULinmCU-Bs7Y4YDUX3iKVG7YSVllzWFI5Nm5Za19NbDZsUHhqM0N6aEVEd3V6WFlZejJiM1lQS0UwQ3hpSjVleHlPZ0xwRTg4QkE3RDdiT3ZEeU1CcDlFRTVWal9YUXFaVHRrWFNPQ3pnIIEC", jct: "8b783b43d496a9f215405b4a65eecd6a"))
        let info = await client.fetchVideoInfo(bvid: videoId)
        if info == nil {
            throw LangChainError.LoaderError("Subtitle not exist")
        }
        return [Document(page_content: info!.subtitle, metadata: [
            "title": info!.title,
            "desc": info!.desc,
            "thumbnail": info!.thumbnail.replacingOccurrences(of: "http", with: "https")
        ])]
    }
    
    override func type() -> String {
        "Bilibili"
    }
}
