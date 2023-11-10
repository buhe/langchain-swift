//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/10.
//

import Foundation
import NIOPosix
import AsyncHTTPClient

public class TTSTool: BaseTool {
    public override init(callbacks: [BaseCallbackHandler] = []) {
        super.init(callbacks: callbacks)
    }
    public override func name() -> String {
        "TTS"
    }
    
    public override func description() -> String {
        """
        useful for When you want to 
        return file name
"""
    }
    
    public override func _run(args: String) async throws -> String {
        let env = Env.loadEnv()
        
        if let apiKey = env["OPENAI_API_KEY"] {
            let baseUrl = env["OPENAI_API_BASE"] ?? "api.openai.com"
            let eventLoopGroup = ThreadManager.thread
            
            let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
            defer {
                // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
                try? httpClient.syncShutdown()
            }
        }
        return ""
    }
}
