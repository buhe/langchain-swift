//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/16.
//

import Foundation

public protocol Tool {
    // Interface LangChain tools must implement.
    
    func name() -> String
    // The unique name of the tool that clearly communicates its purpose.
    func description() -> String
    
    func _run(args: String) async throws -> String
}
public class BaseTool: Tool {
    let callbacks: [BaseCallbackHandler]
    init(callbacks: [BaseCallbackHandler] = []) {
        self.callbacks = callbacks
    }
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
    
    public func name() -> String {
        ""
    }
    
    public func description() -> String {
        ""
    }
    
    public func _run(args: String) async throws -> String {
        ""
    }
    
    public func run(args: String) async throws -> String {
        callStart(tool: self, input: args)
        let result = try await _run(args: args)
        callEnd(tool: self, output: result)
        return result
    }
    
}
