//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/9/6.
//

import Foundation

public class TransformChain: DefaultChain {
    public init(fn: @escaping (_: String) -> LLMResult, memory: BaseMemory? = nil, outputKey: String? = nil, callbacks: [BaseCallbackHandler] = []) {
        self.fn = fn
        super.init(memory: memory, outputKey: outputKey, callbacks: callbacks)
    }
    let fn: (_ args: String) async -> LLMResult
    public override func call(args: String) async throws -> LLMResult {
        return await fn(args)
    }
}
