//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/9/6.
//

import Foundation
public class BaseCallbackHandler: LLMManagerMixin, ChainManagerMixin, CallbackManagerMixin, ToolManagerMixin {
    public func on_llm_error(error: Error) throws {
        
    }
    
    public func on_llm_start(prompt: String) throws {
        
    }
    
    // Manage callback
    public func on_chain_start(prompts: String) throws {
        
    }
    
    public func on_tool_start(tool: BaseTool, input: String) throws {
        
    }
    
    // Chain callback
    public func on_chain_end(output: String) throws {
        
    }
    
    public func on_chain_error(error: Error) throws {
        
    }
    
    public func on_agent_action(action: AgentAction) throws {
        
    }
    
    public func on_agent_finish(action: AgentFinish) throws {
        
    }

    
    // LLM callback
    public func on_llm_new_token() {
        
    }
    
    public func on_llm_end(output: String) throws {
        
    }
    
    // Tool callback
    public func on_tool_end(tool: BaseTool, output: String) throws {
        
    }
    
    public func on_tool_error(error: Error) throws {
        
    }
}

public protocol LLMManagerMixin {
    func on_llm_new_token()
    
    func on_llm_end(output: String) throws
    
    func on_llm_error(error: Error) throws
}

public protocol ChainManagerMixin {
    func on_chain_end(output: String) throws
    
    func on_chain_error(error: Error) throws
    
    func on_agent_action(action: AgentAction) throws
    
    func on_agent_finish(action: AgentFinish) throws
}

public protocol CallbackManagerMixin {
    func on_chain_start(prompts: String) throws
    
    func on_tool_start(tool: BaseTool, input: String) throws
    
    func on_llm_start(prompt: String) throws
}

public protocol ToolManagerMixin {
    func on_tool_end(tool: BaseTool, output: String) throws
    
    func on_tool_error(error: Error) throws
}
