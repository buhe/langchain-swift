//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/9/6.
//

import Foundation
public class BaseCallbackHandler: LLMManagerMixin, ChainManagerMixin, CallbackManagerMixin {
  
    
    // Chain callback
    public func on_chain_end() throws {
        
    }
    
    public func on_chain_start(prompts: String) throws {
        
    }
    
    // LLM callback
    public func on_llm_new_token() {
        
    }
    
    public func on_llm_end() {
        
    }
    
    
}

public protocol LLMManagerMixin {
    func on_llm_new_token()
    
    func on_llm_end()
}

public protocol ChainManagerMixin {
    func on_chain_end() throws
    
    
}

public protocol CallbackManagerMixin {
    func on_chain_start(prompts: String) throws
}
