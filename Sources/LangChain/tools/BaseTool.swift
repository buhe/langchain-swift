//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/16.
//

import Foundation

public protocol BaseTool {
    // Interface LangChain tools must implement.
    
    func name() -> String
    // The unique name of the tool that clearly communicates its purpose.
    func description() -> String
    
    func _run(args: String) async throws -> String
}

struct ToolHelper {
    let callbacks: [BaseCallbackHandler]
    func callStart(tool: BaseTool, input: String) {
        do {
            for callback in callbacks {
                try callback.on_tool_start(tool: tool, input: input)
            }
        } catch {
            
        }
    }
    
    func callEnd(tool: BaseTool, output: String) {
        do {
            for callback in callbacks {
                try callback.on_tool_end(tool: tool, output: output)
            }
        } catch {
            
        }
    }
}
