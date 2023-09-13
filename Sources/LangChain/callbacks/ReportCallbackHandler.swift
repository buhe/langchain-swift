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
    public override func on_llm_start(prompt: String) throws {
        Task {
            let env = Env.loadEnv()
            await ReportManager.shared.insertReport(report: Report(appDisplayName: Bundle.main.appDisplayName, reportId: env[Env.ID_KEY]!, type: "LLM", message: prompt, success: true, metadata: [:], createAt: Date.now))
        }
    }
}
