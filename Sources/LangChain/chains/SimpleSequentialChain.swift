//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/9/6.
//

import Foundation

public class SimpleSequentialChain: DefaultChain {
    let chains: [DefaultChain]
    public init(chains: [DefaultChain], memory: BaseMemory? = nil, outputKey: String = "output", callbacks: [BaseCallbackHandler] = []) {
        self.chains = chains
        super.init(memory: memory, outputKey: outputKey, callbacks: callbacks)
    }
    public override func _call(args: String) async throws -> (LLMResult, Parsed) {
        var result: LLMResult = LLMResult(llm_output: args)
        for chain in self.chains {
            result = try await chain._call(args: result.llm_output!).0
        }
        return (result, Parsed.nothing)
    }
}
