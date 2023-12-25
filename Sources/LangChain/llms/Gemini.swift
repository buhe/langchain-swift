//
//  File.swift
//  
//
//  Created by 顾艳华 on 12/25/23.
//

import Foundation
import GoogleGenerativeAI

public class Gemini: LLM {
    override func _send(text: String, stops: [String]) async throws -> LLMResult {
        let env = Env.loadEnv()
        
        if let apiKey = env["GOOGLEAI_API_KEY"] {
            let model = GenerativeModel(name: "gemini-pro", apiKey: apiKey)
            let response = try await model.generateContent(text)
            return LLMResult(llm_output: response.text)
        } else {
            print("Please set openai api key.")
            return LLMResult(llm_output: "Please set openai api key.")
        }
    }
}
