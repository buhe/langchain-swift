//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/23.
//

import Foundation



public class InvalidTool: BaseTool {
    let tool_name: String
    
    public init(tool_name: String) {
        self.tool_name = tool_name
    }
    
    public override func name() -> String {
        "invalid_tool"
    }
    
    public override func description() -> String {
        "Called when tool name is invalid."
    }
    
    public override func _run(args: String) async throws -> String {
        "\(tool_name) is not a valid tool, try another one."
    }
    
    
}
