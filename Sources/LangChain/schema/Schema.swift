//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/31.
//

import Foundation
import OpenAIKit
// TODO - remove OpenAIKit

public struct LLMResult {
    init(generation: AsyncThrowingStream<ChatStream, Error>? = nil, llm_output: String? = nil) {
        self.generation = generation
        self.llm_output = llm_output
        self.stream = generation != nil
    }
    public let generation: AsyncThrowingStream<ChatStream, Error>?
    
    public var llm_output: String?
    
    var stream: Bool
    
    mutating func setOutput() async throws {
        if llm_output == nil {
            llm_output = ""
            for try await c in generation! {
                if let message = c.choices.first?.delta.content {
                    llm_output! += message
                }
            }
        }
    }
}
