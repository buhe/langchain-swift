//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/26.
//

import Foundation
public class Serper: BaseTool{
    let client = GoogleSerperAPIWrapper()
    let gl: String
    let hl: String
    public init(gl: String = "us", hl: String = "en", callbacks: [BaseCallbackHandler] = []) {
        self.gl = gl
        self.hl = hl
        super.init(callbacks: callbacks)
    }
    public override func name() -> String {
        "Google Serper Results JSON"
    }
    
    public override func description() -> String {
        """
A low-cost Google Search API.
Useful for when you need to answer questions about current events.
Input should be a search query. Output is a JSON object of the query results
"""
    }
    
    public override func _run(args: String) async throws -> String {
        let json = await client._google_serper_api_results(search_term: args, gl: self.gl, hl: self.hl)
        return json
    }
    
    
}
