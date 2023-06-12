//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/12.
//

import Foundation
protocol Embeddings(ABC):
    // Interface for embedding models.

    func embedDocuments(texts: [String]) -> [[Float]]
       
    func embedQuery(text: String) -> [Float]
