//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/19.
//

import Foundation
public class DefaultChain: Chain {
    public func call(args: Any) async throws {
        print("call base.")
    }
    
    public func run(args: Any) async {
        do {
            try await self.call(args: args)
        } catch {
            print(error)
        }
    }
}

public protocol Chain {
    func call(args: Any) async throws
}
