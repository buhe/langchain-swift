//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/9/6.
//

import Foundation

public class StdOutCallbackHandler: BaseCallbackHandler {
    public override init() {
    }
    public override func on_chain_end(output: String) {
        print("💁🏻‍♂️", "[DEBUG] Finished chain, output is '\(output)'.")
    }
    
    public override func on_chain_start(prompts: String) {
        print("💁🏻‍♂️", "[DEBUG] Entering new {class_name} chain. with '\(prompts)'..")
    }
    
//    public override func on_llm_end(output: String) {
//        
//    }
    
    public override func on_tool_start(tool: BaseTool, input: String) throws {
        print("💁🏻‍♂️", "[DEBUG] Entering Tool of \(tool.name()) ,desc: \(tool.description()) with '\(input)'..")
    }
    
    public override func on_tool_end(tool: BaseTool, output: String) throws {
        print("💁🏻‍♂️", "[DEBUG] Finished Tool of \(tool.name()) ,desc: \(tool.description()), output is '\(output)'.")
    }
    
    public override func on_agent_action(action: AgentAction) throws {
        print("💁🏻‍♂️", "[DEBUG] Agent step is \(action.action), log: '\(action.log)'.")
    }
    
    public override func on_agent_finish(action: AgentFinish) throws {
        print("💁🏻‍♂️", "[DEBUG] Agent finish: \(action.final)")
    }
    
}
