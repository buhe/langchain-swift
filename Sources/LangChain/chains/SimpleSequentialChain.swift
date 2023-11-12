//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/9/6.
//

import Foundation

public class SimpleSequentialChain: DefaultChain {
    let chains: [DefaultChain]
    public init(chains: [DefaultChain], memory: BaseMemory? = nil, outputKey: String = "output", inputKey: String = "input", callbacks: [BaseCallbackHandler] = []) {
        self.chains = chains
        super.init(memory: memory, outputKey: outputKey, inputKey: inputKey, callbacks: callbacks)
    }
    public override func _call(args: String) async -> (LLMResult?, Parsed) {
        var result: LLMResult? = LLMResult(llm_output: args)
        for chain in self.chains {
            if result != nil {
                result = await chain._call(args: result!.llm_output!).0
            } else {
                print("A chain of SimpleSequentialChain fail")
            }
        }
        return (result, Parsed.nothing)
    }
}
