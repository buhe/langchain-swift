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
    }
    let generation: AsyncThrowingStream<ChatStream, Error>?
    
    var llm_output: String?
    
    mutating func setOutput() {
        if llm_output == nil {
            // for-each generation
            llm_output = "" // TODO
        }
    }
}
