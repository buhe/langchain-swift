//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/10.
//

import Foundation

public class LLM {
    public init(callbacks: [BaseCallbackHandler] = []) {
        self.callbacks = callbacks
    }
    let callbacks: [BaseCallbackHandler]
    
    func send(text: String, stops: [String]) async -> LLMResult {
        
        let llmResult = await _send(text: text, stops: stops)
        
        return llmResult
    }
    
    func _send(text: String, stops: [String]) async -> LLMResult {
        LLMResult()
    }
}
