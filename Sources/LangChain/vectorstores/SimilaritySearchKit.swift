//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/18.
//

import Foundation
import SimilaritySearchKit

struct LangChainEmbeddingBridge: EmbeddingsProtocol {
    
    var tokenizer: T?
    
    var model: Model?

    class  Model {
        
    }
    class T: TokenizerProtocol {
        func tokenize(text: String) -> [String] {
            []
        }
        
        func detokenize(tokens: [String]) -> String {
            ""
        }
        
        
    }
    let embeddings: Embeddings
    func encode(sentence: String) async -> [Float]? {
        await embeddings.embedQuery(text: sentence)
    }
    
    
}
public class SimilaritySearchKit: VectorStore {
    let vs: SimilarityIndex
    
    init(embeddings: Embeddings) async {
        self.vs =  await SimilarityIndex(
            model: LangChainEmbeddingBridge(embeddings: embeddings),
            metric: CosineSimilarity()
        )
    }
    
    override func similaritySearch(query: String, k: Int) async -> [MatchedModel] {
        await vs.search(query, top: k).map{MatchedModel(content: $0.text, similarity: $0.score, metadata: $0.metadata)}
    }
    
    override func addText(text: String, metadata: [String: String]) async {
        await vs.addItem(id: UUID().uuidString, text: text, metadata: metadata)
    }
}
