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
        callStart(prompt: text)
        do {
            let llmResult = try await _send(text: text, stops: stops)
            if !llmResult.stream {
                callEnd(output: llmResult.llm_output!)
            } else {
                callEnd(output: "[LLM is streamable]")
            }
            return llmResult
        } catch {
            callCatch(error: error)
            return LLMResult()
        }
        
    }
    
    
    func callEnd(output: String) {
        for callback in self.callbacks {
            do {
                try callback.on_llm_end(output: output)
            } catch {
                print("call LLM end callback errer: \(error)")
            }
        }
    }
    
    func callStart(prompt: String) {
        for callback in self.callbacks {
            do {
                try callback.on_llm_start(prompt: prompt)
            } catch {
                print("call LLM start callback errer: \(error)")
            }
        }
    }
    
    func callCatch(error: Error) {
        for callback in self.callbacks {
            do {
                try callback.on_llm_error(error: error)
            } catch {
                print("call LLM start callback errer: \(error)")
            }
        }
    }
    
    func _send(text: String, stops: [String]) async throws -> LLMResult {
        LLMResult()
    }
}
