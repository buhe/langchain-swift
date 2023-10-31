//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/9/6.
//

import Foundation

public class TransformChain: DefaultChain {
    public init(fn: @escaping (_: String) -> LLMResult?, memory: BaseMemory? = nil, outputKey: String = "output", inputKey: String = "input", callbacks: [BaseCallbackHandler] = []) {
        self.fn = fn
        super.init(memory: memory, outputKey: outputKey, inputKey: inputKey, callbacks: callbacks)
    }
    let fn: (_ args: String) async -> LLMResult?
    public override func _call(args: String) async -> (LLMResult?, Parsed) {
        return (await fn(args), Parsed.nothing)
    }
}
