//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/7/31.
//

import AsyncHTTPClient
import Foundation
import NIOPosix
import SwiftyJSON

public struct BilibiliClient {
    let credential: BilibiliCredential
    
    func fetchVideoInfo(bvid: String) async -> BilibiliVideo? {
        let eventLoopGroup = ThreadManager.thread
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        defer {
            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
            try? httpClient.syncShutdown()
        }
        do {
            var request = HTTPClientRequest(url: String(format: "https://api.bilibili.com/x/web-interface/view?bvid=%@", bvid))
            request.method = .GET

            let response = try await httpClient.execute(request, timeout: .seconds(30))
            if response.status == .ok {
                let str = String(buffer: try await response.body.collect(upTo: 1024 * 1024))
                let json = try JSON(data: str.data(using: .utf8)!)
                let aid = json["data"]["aid"].intValue
                let cid = json["data"]["cid"].intValue
                let title = json["data"]["title"].stringValue
                let desc = json["data"]["desc"].stringValue
                let thumbnail = json["data"]["pic"].stringValue
                let url = await fetchSubtitleUrl(cid: cid, aid: aid, httpClient: httpClient)
                let subtitle = await fetchSubtitle(url: url, httpClient: httpClient)
                print("aid: \(aid) cid: \(cid) title: \(title) desc: \(desc)")
                if let subtitle = subtitle {
                    return BilibiliVideo(title: title, desc: desc, subtitle: subtitle, thumbnail: thumbnail)
                } else {
                    print("fetch subtitle error")
                    return nil
                }
            } else {
                // handle remote error
                print("get bilibili video info code is not 200.\(response.body)")
                return nil
            }
        } catch {
            // handle error
            print(error)
            return nil
        }
    }
    
    func fetchSubtitleUrl(cid: Int, aid: Int, httpClient: HTTPClient) async -> String? {
        do {
            var request = HTTPClientRequest(url: String(format: "https://api.bilibili.com/x/player/v2?cid=%@&aid=%@", "\(cid)", "\(aid)"))
            request.method = .GET
            request.headers.add(name: "Cookie", value: String(format: "SESSDATA=%@; bili_jct=%@; sid=7w4jjb7i", credential.sessin, credential.jct))
            let response = try await httpClient.execute(request, timeout: .seconds(30))
            if response.status == .ok {
                let str = String(buffer: try await response.body.collect(upTo: 1024 * 1024))
                let json = try JSON(data: str.data(using: .utf8)!)
                let subtitle = json["data"]["subtitle"]["subtitles"].arrayValue.first?["subtitle_url"].stringValue
                return subtitle
            } else {
                // handle remote error
                print("get bilibili subtitle url code is not 200.\(response.body)")
                return nil
            }
        } catch {
            // handle error
            print("get bilibili subtitle url error")
            print(error)
            return nil
        }
    }
    
    func fetchSubtitle(url: String?, httpClient: HTTPClient) async -> String? {
        if url == nil {
            return nil
        }
        do {
            let completeUrl = String(format: "https:%@", url!)
            print(completeUrl)
            var request = HTTPClientRequest(url: completeUrl)
            request.method = .GET
            let response = try await httpClient.execute(request, timeout: .seconds(30))
            if response.status == .ok {
                let str = String(buffer: try await response.body.collect(upTo: 1024 * 1024))
                let json = try JSON(data: str.data(using: .utf8)!)
                let subtitles = json["body"].arrayValue
                var subtitle = ""
                subtitle = subtitles.map {
                    $0["content"].stringValue
                }.joined(separator: " ")
                return subtitle
            } else {
                // handle remote error
                print("get bilibili video subtitle code is not 200.\(response.body)")
                return nil
            }
        } catch {
            // handle error
            print("get bilibili video subtitle error")
            print(error)
            return nil
        }
    }
    
    public static func getLongUrl(short: String) async -> String? {
        let eventLoopGroup = ThreadManager.thread

        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup), configuration: HTTPClient.Configuration(redirectConfiguration: .disallow))
        do {
            var request = HTTPClientRequest(url: short)
            request.method = .GET
            defer {
                // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
                try? httpClient.syncShutdown()
            }
            let response = try await httpClient.execute(request, timeout: .seconds(30))
            if response.status == .found {
                let long = response.headers.first(name: "Location")!
//                print("long: \(long)")
                return long
            } else {
                // handle remote error
                print("get bilibili lang url error.\(response.body)")
                return nil
            }
        } catch {
            // handle error
            print(error)
            return nil
        }
    }
    
}
