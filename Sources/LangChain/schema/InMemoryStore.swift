//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/17.
//

import Foundation
public class InMemoryStore: BaseStore {
    var store:[String: String] = [:]
    public override init() {
        super.init()
    }
    public override func mget(keys: [String]) async -> [String] {
        var values: [String] = []
        for k in keys {
            let v = self.store[k]
            if v != nil {
                values.append(v!)
            }
        }
        return values
    }
    
    public override func mset(kvpairs: [(String, String)]) async {
        for kv in kvpairs {
            self.store[kv.0] = kv.1
        }
    }
    
    public override func mdelete(keys: [String]) async {
        for k in keys {
            self.store.removeValue(forKey: k)
        }
    }
    
    public override func keys(prefix: String? = nil) async -> [String] {
        if prefix == nil {
            return Array(self.store.keys)
        } else {
            var matched: [String] = []
            for k in self.store.keys {
                if k.hasPrefix(prefix!) {
                    matched.append(k)
                }
            }
            return matched
        }
    }
}
