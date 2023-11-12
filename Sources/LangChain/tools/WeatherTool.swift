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
        """
        useful for When you want to know about the weather
        Input must be longitude and latitude, such as -78.4:38.5.
"""
    }
    
    public override func _run(args: String) async throws -> String {
        let env = Env.loadEnv()
        
        if let apiKey = env["OPENWEATHER_API_KEY"] {
            do {
                let client = OpenWeatherAPIWrapper()
                let weather = try await client.search(query: args, apiKey: apiKey)
                if let weather = weather {
                    return weather
                } else {
                    throw LangChainError.ToolError
                }
            } catch {
                throw LangChainError.ToolError
            }
        } else {
            print("Please set open weather api key.")
            throw LangChainError.ToolError
        }
    }
    
    
}
