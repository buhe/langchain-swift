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
    
    public override func call(args: Any) async {
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

public struct AgentAction{
    let action: String
    let input: String
}
public struct AgentFinish {
    let final: String
}

public enum ActionStep {
    case action(AgentAction)
    case finish(AgentFinish)
    case error
}
public struct MRKLOutputParser {
    public init() {}
    public func parse(text: String) -> ActionStep {
        if text.contains(FINAL_ANSWER_ACTION) {
            return ActionStep.finish(AgentFinish(final: text.components(separatedBy: FINAL_ANSWER_ACTION)[1]))
        }
        let pattern = "Action\\s*:[\\s]*(.*)[\\s]*Action\\s*Input\\s*:[\\s]*(.*)"
        let regex = try! NSRegularExpression(pattern: pattern)
        
        if let match = regex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) {
            
            let firstCaptureGroup = Range(match.range(at: 1), in: text).map { String(text[$0]) }
            print(firstCaptureGroup!)
            
            
            let secondCaptureGroup = Range(match.range(at: 2), in: text).map { String(text[$0]) }
            print(secondCaptureGroup!)
            return ActionStep.action(AgentAction(action: firstCaptureGroup!, input: secondCaptureGroup!))
        } else {
            return ActionStep.error
        }
    }
}
public class ZeroShotAgent: Agent {
    let output_parser: MRKLOutputParser = MRKLOutputParser()
}
