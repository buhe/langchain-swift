//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/10.
//

import Foundation

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
            let data = await OpenAITTSAPIWrapper().tts(text: args, key: apiKey, base: baseUrl)
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

            guard let path = paths.first else {
                print("无法获取到路径")
                throw LangChainError.ToolError
            }

            let url = path.appendingPathComponent("tts.mp3")
            do {
                try data?.write(to: url)
                print("文件写入成功")
                // TODO voice
                return url.absoluteString
            } catch {
                print("文件写入失败：\(error)")
                throw LangChainError.ToolError
            }
        } else {
            throw LangChainError.ToolError
        }
    }
}
