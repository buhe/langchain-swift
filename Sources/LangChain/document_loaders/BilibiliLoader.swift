//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/7/29.
//

import Foundation

public struct BilibiliLoader: BaseLoader {
    let videoId: String
    
    public func load() async -> [Document] {
        let client = BilibiliClient(credential: BilibiliCredential(sessin: "6376fa3e%2C1705926902%2C0b561%2A71gvy_TPyZMWhUweKjYGT502_5FVZdcv8bfjvwtqdlqm8UjyEiUrkPq1AodolcSjIgBXatNwAAEgA", jct: "330aaac577464e453ea1b070fd1281ea"))
        let info = await client.fetchVideoInfo(bvid: videoId)
        return [Document(page_content: info!.subtitle, metadata: [
            "title": info!.title,
            "desc": info!.desc
        ])]
    }
    
}
