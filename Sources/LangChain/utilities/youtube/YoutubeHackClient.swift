//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/29.
//

import AsyncHTTPClient
import Foundation
import NIOPosix

struct YoutubeHackClient {
    static func list_transcripts(video_id: String) async -> TranscriptList {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        defer {
            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
            try? httpClient.syncShutdown()
        }
        return await TranscriptListFetcher(http_client: httpClient).fetch(video_id: video_id)
    }
}
