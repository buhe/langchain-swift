//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/14.
//

import Foundation

public struct MatchedModel: Encodable, Decodable {
    let content: String?
    let similarity: Float
}
public protocol VectorStore {
    func addText(text: String) async
    
    func similaritySearch(query: String, k: Int) async -> [MatchedModel]
}
