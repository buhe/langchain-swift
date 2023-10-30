//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/10/30.
//

import Foundation
public class BaseCache {
    public init() {}
    public func lookup(prompt: String) -> LLMResult? {
        nil
    }
    public func update(prompt: String, return_val: LLMResult) {
        
    }
    //For test?
    public func clear() {
        
    }
}

public class InMemoryCache: BaseCache {
    
    var memery: [String: LLMResult] = [:]
    public override func lookup(prompt: String) -> LLMResult? {
        print("🍰 Get \(prompt) from cache")
        return memery[prompt]
    }
    public override func update(prompt: String, return_val: LLMResult) {
        print("🍰 Update \(prompt)")
        memery[prompt] = return_val
    }
    public override func clear() {
        memery = [:]
    }
}

public class CoreDataCache: BaseCache {
    
}
