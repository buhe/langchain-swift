//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/23.
//

import Foundation

public struct Dummy: BaseTool {
    public func name() -> String {
        "dummy"
    }
    
    public func description() -> String {
        "Useful for test."
    }
    
    public func _run(args: Any) -> Any {
        "Dummy test"
    }
    
    
}
