//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/17.
//

import Foundation
public class BaseStore {
    func mget(keys: [String]) async -> [String] {
        []
    }
    
    func mset(kvpairs: [(String, String)]) async {
        
    }
    
    func mdelete(keys: [String]) async {
        
    }
    
    func keys(prefix: String? = nil) async -> [String] {
        []
    }
}
