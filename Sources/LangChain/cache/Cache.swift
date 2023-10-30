//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/10/30.
//

import Foundation
import SwiftFileStore

public class BaseCache {
    public init() {}
    public func lookup(prompt: String) async -> LLMResult? {
        nil
    }
    public func update(prompt: String, return_val: LLMResult) async {
        
    }
    //For test?
    public func clear() {
        
    }
}

public class InMemoryCache: BaseCache {
    
    var memery: [String: LLMResult] = [:]
    public override func lookup(prompt: String) async -> LLMResult? {
        print("🍰 Get \(prompt) from cache")
        return memery[prompt]
    }
    public override func update(prompt: String, return_val: LLMResult) async {
        print("🍰 Update \(prompt)")
        memery[prompt] = return_val
    }
    public override func clear() {
        memery = [:]
    }
}
struct LLMCache: Codable, JSONDataRepresentable {
    let key: String
    let value: String
}
public class FileCache: BaseCache {
    let objectStore: FileObjectStore?

    public override init() {
        do {
            self.objectStore = try FileObjectStore.create()
        } catch {
            self.objectStore = nil
        }
    }
    public override func lookup(prompt: String) async -> LLMResult? {
        print("🍰 Get \(prompt) from file")
        do {
            let cache = try await objectStore!.read(key: prompt, namespace: "llm_cache", objectType: LLMCache.self)
            return LLMResult(llm_output: cache?.value)
        } catch {
            return nil
        }
        
        
    }
    public override func update(prompt: String, return_val: LLMResult) async {
        print("🍰 Update \(prompt) at file")
        do {
            let cache = LLMCache(key: prompt, value: return_val.llm_output!)
            try await objectStore!.write(key: cache.key, namespace: "llm_cache", object: cache)
        } catch {
            
        }
    }
    public override func clear() {
        
    }
}
