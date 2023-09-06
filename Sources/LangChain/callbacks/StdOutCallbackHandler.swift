//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/9/6.
//

import Foundation

public class StdOutCallbackHandler: BaseCallbackHandler {
    public override func on_chain_end() {
        print("\n\033[1m> Finished chain.\033[0m")
    }
    
    public override func on_chain_start() {
        print("\n\n\033[1m> Entering new {class_name} chain...\033[0m")
    }
    
}
