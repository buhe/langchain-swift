//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/9/6.
//

import Foundation
public class BaseCallbackHandler: LLMManagerMixin, ChainManagerMixin {
  
    
    // Chain callback
    public func on_chain_end() throws{
        
    }
    
    public func on_chain_start() {
        
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
    
    func on_chain_start()
}
