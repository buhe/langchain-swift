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
        print("💁🏻‍♂️", "[DEBUG] Finished chain, output is \(output).")
    }
    
    public override func on_chain_start(prompts: String) {
        print("💁🏻‍♂️", "[DEBUG] Entering new {class_name} chain. with '\(prompts)'..")
    }
    
//    public override func on_llm_end(output: String) {
//        
//    }
    
}
