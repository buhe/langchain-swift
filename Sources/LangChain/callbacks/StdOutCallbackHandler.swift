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
    public override func on_chain_end(output: String, metadata: [String: String]) {
        print("💁🏻‍♂️", "[DEBUG] Finished chain, output is '\(output)'.")
    }
    
    public override func on_chain_start(prompts: String, metadata: [String: String]) {
        print("💁🏻‍♂️", "[DEBUG] Entering new {class_name} chain. with '\(prompts)'..")
    }
    
    public override func on_chain_error(error: Error, metadata: [String: String]) throws {
        print("💁🏻‍♂️", "[DEBUG] Catch chain error: '\(error.localizedDescription)'")
    }
    
    public override func on_llm_end(output: String, metadata: [String: String]) throws {
        print("💁🏻‍♂️", "[DEBUG] Finished LLM, output is '\(output)'.")
    }
    
    public override func on_tool_start(tool: BaseTool, input: String, metadata: [String: String]) throws {
        print("💁🏻‍♂️", "[DEBUG] Entering Tool of \(tool.name()) ,desc: \(tool.description()) with '\(input)'..")
    }
    
    public override func on_tool_end(tool: BaseTool, output: String, metadata: [String: String]) throws {
        print("💁🏻‍♂️", "[DEBUG] Finished Tool of \(tool.name()) ,desc: \(tool.description()), output is '\(output)'.")
    }
    
    public override func on_agent_start(prompt: String, metadata: [String : String]) throws {
        print("💁🏻‍♂️", "[DEBUG] Entering new Agent. with '\(prompt)'..")
    }
    
    public override func on_agent_action(action: AgentAction, metadata: [String: String]) throws {
        print("💁🏻‍♂️", "[DEBUG] Agent step is \(action.action), log: '\(action.log)'.")
    }
    
    public override func on_agent_finish(action: AgentFinish, metadata: [String: String]) throws {
        print("💁🏻‍♂️", "[DEBUG] Agent finish: \(action.final)")
    }
    
    public override func on_llm_start(prompt: String, metadata: [String: String]) throws {
        print("💁🏻‍♂️", "[DEBUG] Entering new LLM. with '\(prompt)'..")
    }
    
    public override func on_llm_error(error: Error, metadata: [String: String]) throws {
        print("💁🏻‍♂️", "[DEBUG] Catch LLM error: '\(error.localizedDescription)'")
    }
    
    public override func on_loader_start(type: String, metadata: [String : String]) throws {
        print("💁🏻‍♂️", "[DEBUG] Entering new \(type) loader")
    }
    
    public override func on_loader_error(type: String, cause: String, metadata: [String : String]) throws {
        print("💁🏻‍♂️", "[DEBUG] Catch \(type) loader error: '\(cause)'")
    }
    
    public override func on_loader_end(type: String, metadata: [String : String]) throws {
        print("💁🏻‍♂️", "[DEBUG] Finished loader of \(type)")
    }
}
