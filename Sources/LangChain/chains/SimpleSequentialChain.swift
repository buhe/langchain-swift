//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/9/6.
//

import Foundation

public class SimpleSequentialChain: DefaultChain {
    let chains: [DefaultChain]
    public init(chains: [DefaultChain]) {
        self.chains = chains
    }
    public override func call(args: String) async throws -> LLMResult {
        var result: LLMResult = LLMResult(llm_output: args)
        for chain in self.chains {
            result = try await chain.call(args: result.llm_output!)
        }
        return result
    }
}
