//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/7/4.
//

import AsyncHTTPClient
import Foundation
import NIOPosix
import SwiftyJSON

struct YoutubeInfoFetcher {
    func fetch(http_client: HTTPClient, video_id: String) async -> YoutubeInfo? {
        let url = "https://www.youtube.com/youtubei/v1/player?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8"
        
        let requestBody = YoutubeInfoRequest(videoId: video_id, context: YoutubeInfoRequestContext(client: YoutubeInfoRequestContextClient(clientName: "WEB", clientVersion: "2.20210721.00.00")))
        do {
            var request = HTTPClientRequest(url: url)
            request.method = .POST
            request.headers.add(name: "Content-Type", value: "application/json")
            request.body = .bytes(try! JSONEncoder().encode(requestBody))
            
            let response = try await http_client.execute(request, timeout: .seconds(30))
            if response.status == .ok {
                let plain = String(buffer: try await response.body.collect(upTo: 1024 * 1024))
                return YoutubeInfoParse().parse(plain_data: plain)
            } else {
                // handle remote error
                print("http code is not 200.")
                return nil
            }
        } catch {
            // handle error
            print(error)
            return nil
        }
    }
    
}
struct YoutubeInfoRequestContextClient: Encodable {
    let clientName: String
    let clientVersion: String
}
struct YoutubeInfoRequestContext: Encodable {
    let client: YoutubeInfoRequestContextClient
}
struct YoutubeInfoRequest: Encodable {
    let videoId: String
    let context: YoutubeInfoRequestContext
}

public struct YoutubeInfo {
    let title: String
    let description: String
    let thumbnail: String
}

struct YoutubeInfoParse {
    func parse(plain_data: String) -> YoutubeInfo {
        let tag = "videoDetails"
        let json = try! JSON(data:
                                plain_data.data(using: .utf8)!
                   )
        let detail = json[tag]
        return YoutubeInfo(title: detail["title"].stringValue, description: detail["shortDescription"].stringValue, thumbnail: detail["thumbnail"]["thumbnails"][0]["url"].stringValue)
    }
}
