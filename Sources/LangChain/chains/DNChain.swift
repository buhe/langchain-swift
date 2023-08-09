//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/9.
//

import Foundation
public class DNChain: DefaultChain {
    public init() {
        
    }
    public override func call(args: String) async throws -> String {
        print("Do nothing.")
        return ""
    }
    
}
