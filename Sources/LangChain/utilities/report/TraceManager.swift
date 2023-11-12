//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/9/11.
//

import AsyncHTTPClient
import Foundation
import NIOPosix

struct Report: Codable {
    let appDisplayName: String?
    let reportId: String
    let type: String
    let message: String
    let metadata: [String: String]
    let createAt: Date
}

struct TraceManager {
//    var reports: [Report] = []
    static let REPORT_URL = "http://192.168.31.60:8083/rest/agent"
    static var shared: TraceManager = TraceManager()
    
    mutating func insertReport(report: Report) async {
//        reports.append(report)
        // TODO: end or error - start time, remove start entry at memery
        await sendServer(report: report)
    }
    
    func sendServer(report: Report) async {
        // TODO: Http keep alive
        let eventLoopGroup = ThreadManager.thread

        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        defer {
            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
            try? httpClient.syncShutdown()
        }
        do {
            var request = HTTPClientRequest(url: TraceManager.REPORT_URL)
            request.method = .POST
            request.headers.add(name: "Content-Type", value: "application/json")
            let requestBody = try! JSONEncoder().encode(report)
            request.body = .bytes(requestBody)

            let response = try await httpClient.execute(request, timeout: .seconds(30))
            if response.status == .ok {
                let _ = String(buffer: try await response.body.collect(upTo: 1024 * 1024))
            } else {
                // handle remote error
                print("http code is not 200.")
            }
        } catch {
            // handle error
            print(error)
        }
    }
}

extension Bundle {
    var appDisplayName: String? {
        return infoDictionary?["CFBundleExecutable"] as? String
    }
}
