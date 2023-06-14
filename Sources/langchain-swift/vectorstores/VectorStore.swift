//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/14.
//

import Foundation
struct DocModel: Encodable, Decodable {
    let content: String?
    let embedding: [Float]
}
public struct MactchedModel {
    let content: String?
    let similarity: Float
}
public protocol VectorStore {
    func addTexts(texts: [String]) async
    
    func similaritySearch(query: String, k: Int) async -> [MactchedModel]
}
