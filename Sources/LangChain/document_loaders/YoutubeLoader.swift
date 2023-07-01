//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/29.
//

import Foundation
import AsyncHTTPClient
import Foundation
import NIOPosix


public struct YoutubeLoader: BaseLoader {
    let video_id: String
    let language: String
    public init(video_id: String, language: String) {
        self.video_id = video_id
        self.language = language
    }
    public func load() async -> [Document] {
        let metadata = ["source": self.video_id]
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        defer {
            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
            try? httpClient.syncShutdown()
        }
        
        var transcript_list = await YoutubeHackClient.list_transcripts(video_id: self.video_id, httpClient: httpClient)
        if transcript_list.generated_transcripts.isEmpty && transcript_list.manually_created_transcripts.isEmpty {
            return [Document(page_content: "Content is empty.", metadata: metadata)]
        }
        var transcript = transcript_list.find_transcript(language_codes: [self.language])
        if transcript == nil {
            let en_transcript = transcript_list.manually_created_transcripts.first!.value
            transcript = en_transcript.translate(language_code: self.language)
        }
        let transcript_pieces = await transcript!.fetch()
        
        let text = transcript_pieces!.map {$0["text"]!}.joined(separator: " ")
        
        return [Document(page_content: text, metadata: metadata)]
    
    }
    
    
}
