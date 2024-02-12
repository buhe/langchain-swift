//
//  File.swift
//  
//
//  Created by 顾艳华 on 2/11/24.
//

import Foundation
import SimilaritySearchKitDistilbert

@available(macOS 13.0, *)
public struct Distilbert: Embeddings {
    let n = DistilbertEmbeddings()
    public init() {
        
    }
    
    
    public func embedQuery(text: String) async -> [Float] {
        await n.encode(sentence: text)!
    }
}
