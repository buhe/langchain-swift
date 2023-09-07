//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/27.
//

import Foundation
import JavaScriptCore


public class JavascriptREPLTool: BaseTool {
    var context: JSContext = JSContext()

    public override func name() -> String {
        "javascript_REPL"
    }
    
    public override func description() -> String {
        """
        A javascript shell. Use this to execute javascript commands.
        Input should be a valid javascript command.
        If you want to see the output of a value, you should print it out
        with `console.log(...)`.
"""
    }
    
    public override func _run(args: String) async throws -> String {
        let jsResult = context.evaluateScript(args)
        if jsResult != nil {
            return (jsResult?.toString())!
        } else {
            return "javascript eval error."
        }
    }
    
    
}
