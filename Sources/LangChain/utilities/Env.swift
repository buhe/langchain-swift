//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/11.
//

import Foundation
public struct Env {
//    static var printTrace = true
    static var printTrace = false
    static let ID_KEY = "TRACE_ID"
    static let SKIP_TRACE_KEY = "SKIP_TRACE"
    static let TRACE_ID = UUID().uuidString + "-" + UUID().uuidString
    static var env: [String: String] = [:]
    static var trace = false
    public static func initSet(_ env: [String: String]) {
        Env.env = env
    }
    private static func mergeFromVar(file: [String: String]) -> [String: String] {
        var result = file
        for (k, v) in Env.env {
            result.updateValue(v, forKey: k)
        }
        return result
    }
    static func addTraceCallbak() -> Bool {
        let _ = loadEnv()
        return trace
    }
    static func loadEnv() -> [String: String] {
        var env: [String: String] = Env.env
        if let envPath = Bundle.main.path(forResource: "env", ofType: "txt") {
            do {
                
                let envContent = try String(contentsOfFile: envPath)
                
                let envLines = envContent.components(separatedBy: .newlines)
                for line in envLines {
                    
                    if line.hasPrefix("#") { continue }
                    
                    let parts = line.components(separatedBy: "=")
                    guard parts.count == 2 else { continue }
                    let key = parts[0].trimmingCharacters(in: .whitespaces)
                    let value = parts[1].trimmingCharacters(in: .whitespaces)
                    
                    env[key] = value
                }
            } catch {
                print("Unable to load .env file: \(error)")
            }
            env = mergeFromVar(file: env)
            
        }
        if printTrace {
            if env[Env.ID_KEY] == nil && (env[Env.SKIP_TRACE_KEY] == nil || env[Env.SKIP_TRACE_KEY] == "false") {
                print("⚠️ [WARING]", "\(Env.ID_KEY) not found, Please enter '\(Env.ID_KEY)=\(Env.TRACE_ID)' to trace LLM or enter '\(Env.SKIP_TRACE_KEY)=true' to skip trace at env.txt .")
                    
            } else {
                if env[Env.ID_KEY] != nil {
                    print("✅ [INFO]", "Found trace id: \(env[Env.ID_KEY]!) .")
                    trace = true
                }
                
                if env[Env.SKIP_TRACE_KEY] == "true" {
                    print("✅ [INFO]", "Skip trace.")
                    trace = false
                }
            }
            printTrace = false
        }
        return env
    }
}

