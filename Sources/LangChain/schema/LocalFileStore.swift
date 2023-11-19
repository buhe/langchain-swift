//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/19.
//

import Foundation
import SwiftFileStore
struct StoreEntry: Codable, JSONDataRepresentable {
    let key: String
    let value: String
}
public class LocalFileStore: BaseStore {
    let objectStore: FileObjectStore?

    public override init() {
        do {
            self.objectStore = try FileObjectStore.create()
        } catch {
            self.objectStore = nil
        }
    }
    
    override func mget(keys: [String]) -> [String] {
        []
    }
    
    override func mset(kvpairs: [(String, String)]) {
        
    }
    
    override func mdelete(keys: [String]) {
        
    }
    
    override func keys(prefix: String? = nil) -> [String] {
        []
    }
}
