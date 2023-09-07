//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/23.
//

import Foundation
//class WeatherTool(BaseTool):
//    name = "Weather"
//    description = "useful for When you want to know about the weather"
//
//    def _run(self, query: str) -> str:
//        return "Sunny^_^"
//
//    async def _arun(self, query: str) -> str:
//        """Use the tool asynchronously."""
//        raise NotImplementedError("BingSearchRun does not support async")

public class WeatherTool: BaseTool {

    public override init(callbacks: [BaseCallbackHandler] = []) {
        super.init(callbacks: callbacks)
    }
    public override func name() -> String {
        "Weather"
    }
    
    public override func description() -> String {
        "useful for When you want to know about the weather"
    }
    
    public override func _run(args: String) async throws -> String {
        let result = "Sunny^_^"
        return result
    }
    
    
}
