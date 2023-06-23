//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/23.
//

import Foundation



public struct InvalidTool {
    let tool_name: String
    
    public func name() -> String {
        "invalid_tool"
    }
    
    public func description() -> String {
        "Called when tool name is invalid."
    }
    
    public func _run(args: String)  -> String {
        "\(tool_name) is not a valid tool, try another one."
    }
    
    
}
