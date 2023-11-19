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
        print("🍰 Update \(kvpairs) at file")
        do {
            for kv in kvpairs {
                if let data = kv.0.data(using: .utf8) {
                    let base64 = data.base64EncodedString()
                    let cache = StoreEntry(key: kv.0, value: kv.1)
                    try await objectStore!.write(key: base64.sha256(), namespace: LocalFileStore.STORE_NS, object: cache)
                }
            }
        } catch {
            print("FileStore set failed")
        }
    }
    
    override func mdelete(keys: [String]) async {
        print("🍰 Delete \(keys) at file")
        do {
            for key in keys {
                if let data = key.data(using: .utf8) {
                    let base64 = data.base64EncodedString()
                    try await objectStore!.remove(key: base64.sha256(), namespace: LocalFileStore.STORE_NS)
                }
            }
        } catch {
            print("FileStore set failed")
        }
    }
    
    override func keys(prefix: String? = nil) async -> [String] {
        if prefix == nil {
            print("🍰 Get all keys from file")
            return Array(await self.allKeys())
        } else {
            print("🍰 Get keys \(prefix!) from file")
            var matched: [String] = []
            for k in await self.allKeys() {
                if k.hasPrefix(prefix!) {
                    matched.append(k)
                }
            }
            return matched
        }
        
    }
    
    func allKeys() async -> [String] {
        [] // TODO
    }
}
