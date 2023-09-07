//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/23.
//

import Foundation

public class Dummy: BaseTool {
    public override func name() -> String {
        "dummy"
    }
    
    public override func description() -> String {
        "Useful for test."
    }
    
    public override func _run(args: String) async throws -> String {
        "Dummy test"
    }
    
    
}
