//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/9.
//

import Foundation
public class DNChain: DefaultChain {
    public override init(memory: BaseMemory? = nil, outputKey: String? = nil, callbacks: [BaseCallbackHandler] = []) {
        super.init(memory: memory, outputKey: outputKey, callbacks: callbacks)
    }
    public override func _call(args: String) async throws -> (LLMResult, Parsed) {
//        print("Do nothing.")
        return (LLMResult(), Parsed.nothing)
    }
    
}
