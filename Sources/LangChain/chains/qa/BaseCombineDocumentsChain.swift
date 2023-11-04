//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/4.
//

import Foundation

public class BaseCombineDocumentsChain: DefaultChain {
    public override func _callDict(args: [String: String]) async -> (LLMResult?, Parsed) {
        print("call combine base.")
        let output = await self.combine_docs(docs: args["docs"]!, question: args["question"]!)
        return (LLMResult(llm_output: output), Parsed.unimplemented)
    }
    
    public func combine_docs(docs: String, question: String) async -> String {
        ""
    }
}
