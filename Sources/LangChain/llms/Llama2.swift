//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/9/7.
//



// https://www.llama-api.com/account/api-token
import Foundation
import NIOPosix
import AsyncHTTPClient
import OpenAIKit

public class Llama2: LLM {
    
    let temperature: Double
    
    public init(temperature: Double = 0.0) {
        self.temperature = temperature
    }
    
    public override func _send(text: String, stops: [String] = []) async -> LLMResult {
        let env = Env.loadEnv()
        
        if let apiKey = env["LLAMA2_API_KEY"] {
            let responce = await LlamaAPIWrapper().execute(text: text, key: apiKey, temperature: self.temperature, max_tokens: 2048, topP: 1.0, n: 1, stops: [])
            return LLMResult(llm_output: responce)
        } else {
            print("Please set llama2 api key.")
            return LLMResult(llm_output: "Please set llama2 api key.")
        }
        
    }
    
    
}


