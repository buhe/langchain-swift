//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/19.
//

import Foundation

public class LLMChain: DefaultChain {
    let llm: LLM
    public init(llm: LLM) {
        self.llm = llm
    }
    public override func call(args: Any) throws {
        print("call child....")
    }
    
}
