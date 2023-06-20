//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/19.
//

import Foundation
public class DefaultChain: Chain {
    public func call(args: Any) throws{
        print("call base.")
    }
    
    public func run(args: Any) {
        do {
            try self.call(args: args)
        } catch {
            print(error)
        }
    }
}

public protocol Chain {
    func call(args: Any) throws
}
