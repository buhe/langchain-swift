//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/26.
//

import Foundation
public struct Serper: BaseTool{
    let client = GoogleSerperAPIWrapper()
    public init(){}
    public func name() -> String {
        "Google Serrper Results JSON"
    }
    
    public func description() -> String {
        """
A low-cost Google Search API.
Useful for when you need to answer questions about current events.
Input should be a search query. Output is a JSON object of the query results
"""
    }
    
    public func _run(args: String) async throws -> String {
        let json = await client._google_serper_api_results(search_term: args)
        return json
    }
    
    
}
