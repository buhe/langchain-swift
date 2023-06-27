//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/26.
//
import AsyncHTTPClient
import Foundation
import NIOPosix

struct GooglrRequest: Encodable {
    let k: Int
    let gl: String
    let hl: String
    let q: String
}
struct GoogleSerperAPIWrapper {
//    def _google_serper_api_results(
//            self, search_term: str, search_type: str = "search", **kwargs: Any
//        ) -> dict:
//            headers = {
//                "X-API-KEY": self.serper_api_key or "",
//                "Content-Type": "application/json",
//            }
//            params = {
//                "q": search_term,
//                **{key: value for key, value in kwargs.items() if value is not None},
//            }
//            response = requests.post(
//                f"https://google.serper.dev/{search_type}", headers=headers, params=params
//            )
//            response.raise_for_status()
//            search_results = response.json()
//            return search_results
    
    func _google_serper_api_results(search_term: String, search_type: String = "search", k: Int = 10, gl: String = "us", hl: String = "en") async -> String {
        let env = loadEnv()
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        do {
            var request = HTTPClientRequest(url: "https://google.serper.dev/\(search_type)")
            request.method = .POST
            request.headers.add(name: "X-API-KEY", value: env["SERPER_API_KEY"]!)
            request.headers.add(name: "Content-Type", value: "application/json")
            let requestBody = try! JSONEncoder().encode(GooglrRequest(k: k, gl: gl, hl: hl, q: search_term))
            request.body = .bytes(requestBody)
//            let str = String(data: requestBody, encoding: .utf8)!
//            print(str)
            defer {
                // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
                try? httpClient.syncShutdown()
            }
            let response = try await httpClient.execute(request, timeout: .seconds(30))
            if response.status == .ok {
                // handle response
//                let body = try await response.body.collect(upTo: 1024 * 1024) // 1 MB
//                print(body.getString(at: 0, length: body.readableBytes)!)
                var strResponse = ""
                for try await r in response.body {
                    strResponse += r.getString(at: 0, length: r.readableBytes)!
                }
//                print(strResponse)
                return strResponse
            } else {
                // handle remote error
                print("http code is not 200.")
                return "Bad requset."
            }
        } catch {
            // handle error
            print(error)
            return "Bad request."
        }
    }
}
