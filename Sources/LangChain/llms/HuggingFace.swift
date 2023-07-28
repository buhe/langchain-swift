//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/7/27.
//

import Foundation
public struct HuggingFace: LLM {
    let repo: String
    let task: String
    
    public init(repo: String, task: String = "text-generation") {
        self.repo = repo
        self.task = task
    }
    
    public func send(text: String, stops: [String] = []) async -> String {
        let wrapper = InferenceApi(repo: repo, task: task)
        let response = await wrapper.inference(text: text)
        let result = response[0]["generated_text"].stringValue
        var result2 = String(result[text.endIndex...])
        print("inf result:\(result2)")
        
        if !stops.isEmpty {
            result2 = result2.components(separatedBy: stops[0])[0]
        }
        return result2
    }
    
}
