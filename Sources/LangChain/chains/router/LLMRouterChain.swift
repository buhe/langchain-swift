//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/7.
//

import Foundation

public struct Route {
    let destination: String
    let next_inputs: String
}

public class LLMRouterChain: DefaultChain {
    let llmChain: LLMChain
    
    public init(llmChain: LLMChain) {
        self.llmChain = llmChain
    }
    
    public func route(args: [String: String]) async -> Route {
        let parsed = await llmChain.predict_and_parse(args: args)
        // check and route
        return Route(destination: "", next_inputs: "")
    }
    
}
