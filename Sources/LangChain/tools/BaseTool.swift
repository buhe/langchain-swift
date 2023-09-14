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
    static let TOOL_REQ_ID = "tool_req_id"
    static let TOOL_COST_KEY = "cost"
    static let TOOL_NAME_KEY = "tool_name"
    let callbacks: [BaseCallbackHandler]
    init(callbacks: [BaseCallbackHandler] = []) {
        var cbs: [BaseCallbackHandler] = callbacks
        if Env.addTraceCallbak() && !cbs.contains(where: { item in item is TraceCallbackHandler}) {
            cbs.append(TraceCallbackHandler())
        }
//        assert(cbs.count == 1)
        self.callbacks = cbs
    }
    func callStart(tool: BaseTool, input: String, reqId: String) {
        do {
            for callback in callbacks {
                try callback.on_tool_start(tool: tool, input: input, metadata: [BaseTool.TOOL_REQ_ID: reqId, BaseTool.TOOL_NAME_KEY: tool.name()])
            }
        } catch {
            
        }
    }
    
    func callEnd(tool: BaseTool, output: String, reqId: String, cost: Double) {
        do {
            for callback in callbacks {
                try callback.on_tool_end(tool: tool, output: output, metadata: [BaseTool.TOOL_REQ_ID: reqId, BaseTool.TOOL_COST_KEY: "\(cost)", BaseTool.TOOL_NAME_KEY: tool.name()])
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
        let reqId = UUID().uuidString
        var cost = 0.0
        let now = Date.now.timeIntervalSince1970
        callStart(tool: self, input: args, reqId: reqId)
        let result = try await _run(args: args)
        cost = Date.now.timeIntervalSince1970 - now
        callEnd(tool: self, output: result, reqId: reqId, cost: cost)
        return result
    }
    
}
