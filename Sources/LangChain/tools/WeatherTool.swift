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

public struct WeatherTool: BaseTool {
    public init() {}
    public func name() -> String {
        "Weather"
    }
    
    public func description() -> String {
        "useful for When you want to know about the weather"
    }
    
    public func _run(args: String) throws -> String {
        "Sunny^_^"
    }
    
    
}
