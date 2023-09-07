//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/11.
//

import Foundation
public struct Env {
    static var env: [String: String] = [:]
    public static func initSet(_ env: [String: String]) {
        Env.env = env
    }
    
    static func loadEnv() -> [String: String] {
        if let envPath = Bundle.main.path(forResource: "env", ofType: "txt") {
            var env: [String: String] = [:]
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
            
            return env
        } else {
            return Env.env
        }
    }
}

