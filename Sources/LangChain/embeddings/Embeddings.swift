//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/12.
//

import Foundation
public protocol Embeddings {
    // Interface for embedding models.
    
//    func embedDocuments(texts: [String]) -> [[Float]]
    
    func embedQuery(text: String) async -> [Float]
}
