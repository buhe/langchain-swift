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
        let client = BilibiliClient(credential: BilibiliCredential(sessin: "6376fa3e%2C1705926902%2C0b561%2A71gvy_TPyZMWhUweKjYGT502_5FVZdcv8bfjvwtqdlqm8UjyEiUrkPq1AodolcSjIgBXatNwAAEgA", jct: "330aaac577464e453ea1b070fd1281ea"))
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
