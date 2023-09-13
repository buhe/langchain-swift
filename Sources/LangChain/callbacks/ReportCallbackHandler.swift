//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/9/11.
//

import Foundation

public class ReportCallbackHandler: BaseCallbackHandler {
    public override init() {
    }
    public override func on_llm_start(prompt: String, metadata: [String: String]) throws {
        Task {
            var m = metadata
            m[ReportKey.STEP_START_KEY] = ReportKey.TRUE
            let env = Env.loadEnv()
            await ReportManager.shared.insertReport(report: Report(appDisplayName: Bundle.main.appDisplayName, reportId: env[Env.ID_KEY]!, type: "LLM", message: prompt, metadata: m, createAt: Date.now))
        }
    }
    
    public override func on_llm_end(output: String, metadata: [String: String]) throws {
        Task {
            var m = metadata
            m[ReportKey.STEP_END_KEY] = ReportKey.TRUE
            let env = Env.loadEnv()
            await ReportManager.shared.insertReport(report: Report(appDisplayName: Bundle.main.appDisplayName, reportId: env[Env.ID_KEY]!, type: "LLM", message: output, metadata: m, createAt: Date.now))
        }
    }
}
