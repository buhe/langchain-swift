//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/2.
//

import Foundation
public class WikipediaRetriever: BaseRetriever {
    let client = WikipediaAPIWrapper()
    
    public override func _get_relevant_documents(query: String) async throws -> [Document] {
        try await client.load(query: query)
    }
    
    public override init() {
        
    }
}
