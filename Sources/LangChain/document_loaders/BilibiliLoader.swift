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
        let client = BilibiliClient(credential: BilibiliCredential(sessin: "f3fd16e8%2C1721810527%2C531af%2A12CjAJT4BNVd9Zbd9uAhx99W1XsX6gbi1Js0uHqHKZPGWzS8xLuGdX7kE5x2-DQUFacJYSVnJlYXVwbm9KY2dfS1BENHN5SzZ2NE1wQ2dKLWxqUEMwQVBVN1JiQnh3NjltTDVoM3FURjUwRWt5TDNkdXVQUzFraWVLSnJUdVdMMVhyc25ZcXhFZW53IIEC", jct: "20601a72b51f0448ada0babc5740dc90"))
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
