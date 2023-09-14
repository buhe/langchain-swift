//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/9/11.
//

import Foundation

public class TraceCallbackHandler: BaseCallbackHandler {
    func truncate(_ text: String) -> String {
        String(text.prefix(50))
    }
    
    public override func on_llm_start(prompt: String, metadata: [String: String]) throws {
        Task {
            var m = metadata
            m[ReportKey.STEP_START_KEY] = ReportKey.TRUE
            let env = Env.loadEnv()
            await TraceManager.shared.insertReport(report: Report(appDisplayName: Bundle.main.appDisplayName, reportId: env[Env.ID_KEY]!, type: "LLM", message: truncate(prompt), metadata: m, createAt: Date.now))
        }
    }
    
    public override func on_llm_end(output: String, metadata: [String: String]) throws {
        Task {
            var m = metadata
            m[ReportKey.STEP_END_KEY] = ReportKey.TRUE
            let env = Env.loadEnv()
            await TraceManager.shared.insertReport(report: Report(appDisplayName: Bundle.main.appDisplayName, reportId: env[Env.ID_KEY]!, type: "LLM", message: truncate(output), metadata: m, createAt: Date.now))
        }
    }
    
    public override func on_chain_error(error: Error, metadata: [String: String]) throws {
        Task {
            var m = metadata
            m[ReportKey.STEP_END_KEY] = ReportKey.TRUE
            let env = Env.loadEnv()
            await TraceManager.shared.insertReport(report: Report(appDisplayName: Bundle.main.appDisplayName, reportId: env[Env.ID_KEY]!, type: "Chain", message: truncate(error.localizedDescription), metadata: m, createAt: Date.now))
        }
    }
    
    public override func on_chain_end(output: String, metadata: [String: String]) {
        Task {
            var m = metadata
            m[ReportKey.STEP_END_KEY] = ReportKey.TRUE
            let env = Env.loadEnv()
            await TraceManager.shared.insertReport(report: Report(appDisplayName: Bundle.main.appDisplayName, reportId: env[Env.ID_KEY]!, type: "Chain", message: truncate(output), metadata: m, createAt: Date.now))
        }
    }
    
    public override func on_chain_start(prompts: String, metadata: [String: String]) {
        Task {
            var m = metadata
            m[ReportKey.STEP_START_KEY] = ReportKey.TRUE
            let env = Env.loadEnv()
            await TraceManager.shared.insertReport(report: Report(appDisplayName: Bundle.main.appDisplayName, reportId: env[Env.ID_KEY]!, type: "Chain", message: truncate(prompts), metadata: m, createAt: Date.now))
        }
    }
    
    
    public override func on_tool_start(tool: BaseTool, input: String, metadata: [String: String]) throws {
        Task {
            var m = metadata
            m[ReportKey.STEP_START_KEY] = ReportKey.TRUE
            let env = Env.loadEnv()
            await TraceManager.shared.insertReport(report: Report(appDisplayName: Bundle.main.appDisplayName, reportId: env[Env.ID_KEY]!, type: "Tool", message: truncate(input), metadata: m, createAt: Date.now))
        }
    }
    
    public override func on_tool_end(tool: BaseTool, output: String, metadata: [String: String]) throws {
        Task {
            var m = metadata
            m[ReportKey.STEP_END_KEY] = ReportKey.TRUE
            let env = Env.loadEnv()
            await TraceManager.shared.insertReport(report: Report(appDisplayName: Bundle.main.appDisplayName, reportId: env[Env.ID_KEY]!, type: "Tool", message: truncate(output), metadata: m, createAt: Date.now))
        }
    }
    
    public override func on_agent_start(prompt: String, metadata: [String : String]) throws {
        Task {
            var m = metadata
            m[ReportKey.STEP_START_KEY] = ReportKey.TRUE
            let env = Env.loadEnv()
            await TraceManager.shared.insertReport(report: Report(appDisplayName: Bundle.main.appDisplayName, reportId: env[Env.ID_KEY]!, type: "Agent", message: truncate(prompt), metadata: m, createAt: Date.now))
        }
    }
    
    public override func on_agent_action(action: AgentAction, metadata: [String: String]) throws {
        Task {
            var m = metadata
            m[ReportKey.STEP_END_KEY] = ReportKey.TRUE
            let env = Env.loadEnv()
            await TraceManager.shared.insertReport(report: Report(appDisplayName: Bundle.main.appDisplayName, reportId: env[Env.ID_KEY]!, type: "Agent", message: truncate(action.log), metadata: m, createAt: Date.now))
        }
    }
    
    public override func on_agent_finish(action: AgentFinish, metadata: [String: String]) throws {
        Task {
            var m = metadata
            m[ReportKey.STEP_END_KEY] = ReportKey.TRUE
            let env = Env.loadEnv()
            await TraceManager.shared.insertReport(report: Report(appDisplayName: Bundle.main.appDisplayName, reportId: env[Env.ID_KEY]!, type: "Agent", message: truncate(action.final), metadata: m, createAt: Date.now))
        }
    }
    
    public override func on_llm_error(error: Error, metadata: [String: String]) throws {
        Task {
            var m = metadata
            m[ReportKey.STEP_END_KEY] = ReportKey.TRUE
            let env = Env.loadEnv()
            await TraceManager.shared.insertReport(report: Report(appDisplayName: Bundle.main.appDisplayName, reportId: env[Env.ID_KEY]!, type: "LLM", message: truncate(error.localizedDescription), metadata: m, createAt: Date.now))
        }
    }
}
