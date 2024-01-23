//
//  File.swift
//  
//
//  Created by 顾艳华 on 1/22/24.
//

import Foundation
public class Local {
    
    public init() {
    }
    
    public func _send(text: String, stops: [String] = []) async throws -> LLMResult {
      
        return LLMResult()
    }
    
    func mainCallback(_ str: String, _ time: Double) -> Bool {
        print("\(str)",terminator: "")

        return false
    }
}

