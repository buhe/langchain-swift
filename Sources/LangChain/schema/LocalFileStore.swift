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
    static let STORE_NS = "store"
    public override init() {
        do {
            self.objectStore = try FileObjectStore.create()
        } catch {
            self.objectStore = nil
        }
    }
    
    override func mget(keys: [String]) async -> [String] {
        print("🍰 Get \(keys) from file")
        var values: [String] = []
        do {
            for key in keys {
                if let data = key.data(using: .utf8) {
                    let base64 = data.base64EncodedString()
                    
                    let cache = try await objectStore!.read(key: base64.sha256(), namespace: LocalFileStore.STORE_NS, objectType: StoreEntry.self)
                    if let c = cache {
                        values.append(c.value)
                    }
                }
            }
        } catch {
            print("FileStore get failed")
        }
        return values
    }
    
    override func mset(kvpairs: [(String, String)]) async {
        
    }
    
    override func mdelete(keys: [String]) async {
        
    }
    
    override func keys(prefix: String? = nil) async -> [String] {
        []
    }
}
