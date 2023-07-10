//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/29.
//

import AsyncHTTPClient
import Foundation
import NIOPosix

public struct YoutubeHackClient {
    
    public static func list_transcripts(video_id: String, httpClient: HTTPClient) async -> TranscriptList? {
        return await TranscriptListFetcher(http_client: httpClient).fetch(video_id: video_id)
    }
    
    public static func info(video_id: String, httpClient: HTTPClient) async -> YoutubeInfo? {
        return await YoutubeInfoFetcher().fetch(http_client: httpClient, video_id: video_id)
    }
}
