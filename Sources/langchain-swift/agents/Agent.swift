//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/19.
//

import Foundation
public class AgentExecutor: DefaultChain {
    let agent: Agent
    
    public init(agent: Agent) {
        self.agent = agent
    }
    
    public override func call(args: Any) {
        // chain run -> call -> agent plan -> llm send
        
        // while should_continue and call
    }
}

public func initialize_agent(llm: LLM) -> AgentExecutor {
    return AgentExecutor(agent: ZeroShotAgent(llm_chain: LLMChain(llm: llm)))
}

public class Agent {
    let llm_chain: LLMChain
    
    public init(llm_chain: LLMChain) {
        self.llm_chain = llm_chain
    }
    
    public func plan() {
        
    }
}

public class ZeroShotAgent: Agent {
    
}
