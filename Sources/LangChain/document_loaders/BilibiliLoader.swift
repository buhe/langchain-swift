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
        let env = Env.loadEnv()
        
        if let session = env["BILIBILI_SESSION"], let jct = env["BILIBILI_JCT"] {
            let client = BilibiliClient(credential: BilibiliCredential(sessin: session, jct: jct))
            let info = await client.fetchVideoInfo(bvid: videoId)
            if info == nil {
                throw LangChainError.LoaderError("Subtitle not exist")
            }
            return [Document(page_content: info!.subtitle, metadata: [
                "title": info!.title,
                "desc": info!.desc,
                "thumbnail": info!.thumbnail.replacingOccurrences(of: "http", with: "https")
            ])]
        } else {
            print("BILIBILI_SESSION or BILIBILI_JCT not set.")
            return []
        }
    }
    
    override func type() -> String {
        "Bilibili"
    }
}
