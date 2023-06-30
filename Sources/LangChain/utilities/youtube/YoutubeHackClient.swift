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
    
    static func list_transcripts(video_id: String, httpClient: HTTPClient) async -> TranscriptList {
        return await TranscriptListFetcher(http_client: httpClient).fetch(video_id: video_id)
    }
}
