//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/17.
//

import Foundation
public class BaseStore {
    public func mget(keys: [String]) async -> [String] {
        []
    }
    
    public func mset(kvpairs: [(String, String)]) async {
        
    }
    
    public func mdelete(keys: [String]) async {
        
    }
    
    public func keys(prefix: String? = nil) async -> [String] {
        []
    }
}
