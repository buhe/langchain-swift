//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/7/29.
//

import Foundation
//import BilibiliKit

public struct BilibiliLoader: BaseLoader {
    let videoId: String
    
    public func load() async -> [Document] {
//        let video = BKVideo.bv(videoId)
//        video.getInfo(then: {
//            result in
//            let list = try result.get().subtitles.list
//        })
        return []
    }
    
}
