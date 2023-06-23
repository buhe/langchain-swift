//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/19.
//

import Foundation
public class DefaultChain: Chain {
    public func call(args: String) async throws -> String {
        print("call base.")
        return args
    }
    
    public func run(args: String) async -> String {
        do {
            return try await self.call(args: args)
        } catch {
            print(error)
            return ""
        }
    }
}

public protocol Chain {
    func call(args: String) async throws -> String
}
