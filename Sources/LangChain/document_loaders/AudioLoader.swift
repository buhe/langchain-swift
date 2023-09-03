//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/9/3.
//


import Foundation
import NIOPosix
import AsyncHTTPClient
import OpenAIKit
import AVFoundation

public struct AudioLoader: BaseLoader {
    
    let audio: URL
    let fileName: String
    let mimeType: MIMEType.Audio
    
    public func load() async -> [Document] {
        var docs: [Document] = []
        
        let asset: AVAsset = AVAsset(url: audio)
        // Get the length of the audio file asset
        let duration = CMTimeGetSeconds(asset.duration)
        // Determine how many segments we want
        let numOfSegments = Int(ceil(duration / 60) - 1)
        // For each segment, we need to split it up
        
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
       
        let env = loadEnv()
        
        if let apiKey = env["OPENAI_API_KEY"] {
            let baseUrl = env["OPENAI_API_BASE"] ?? "api.openai.com"

            let configuration = Configuration(apiKey: apiKey, api: API(scheme: .https, host: baseUrl))

            let openAIClient = OpenAIKit.Client(httpClient: httpClient, configuration: configuration)
            defer {
                // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
                try? httpClient.syncShutdown()
            }
            for index in 0...numOfSegments {
                if let url = try! await splitAudio(asset: asset, segment: index) {
                    // TODO - url to data
                    let completion = try! await openAIClient.audio.transcribe(file: Data(), fileName: "\(fileName)_\(index)", mimeType: .m4a)
                    let doc = Document(page_content: completion.text, metadata: ["fileName": "\(fileName)_\(index)", "mimeType": "m4a"])
                    docs.append(doc)
                }
            }
            return docs
        } else {
            print("Please set openai api key.")
            return []
        }
        
    }
    
    func splitAudio(asset: AVAsset, segment: Int) async throws -> URL? {
        // Create a new AVAssetExportSession
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)!
        // Set the output file type to m4a
        exporter.outputFileType = AVFileType.m4a
        // Create our time range for exporting
        let startTime = CMTimeMake(value: Int64(60 * segment), timescale: 1)
        let endTime = CMTimeMake(value: Int64(60 * (segment+1)), timescale: 1)
        // Set the time range for our export session
        exporter.timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
        // Set the output file path
        // TODO - test path
        exporter.outputURL = URL(string: ".\(segment).m4a")
        // Do the actual exporting
        return try await withCheckedThrowingContinuation { continuation in
            exporter.exportAsynchronously(completionHandler: {
                switch exporter.status {
                    case AVAssetExportSession.Status.failed:
                        print("Export failed.")
                        continuation.resume(returning: nil)
                    default:
                        print("Export complete.")
                        let audio = exporter.outputURL!
                        continuation.resume(returning: audio)
                       
                }
            })
        }
       
    }
}
