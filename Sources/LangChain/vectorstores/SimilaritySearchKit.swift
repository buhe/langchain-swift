//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/18.
//

import Foundation

#if os(macOS) || os(iOS) || os(visionOS)
import SimilaritySearchKit

private struct LangChainEmbeddingBridge: EmbeddingsProtocol {
    
    var tokenizer: _T?
    
    var model: _M?

    class  _M {
        
    }
    class _T: TokenizerProtocol {
        func tokenize(text: String) -> [String] {
            []
        }
        
        func detokenize(tokens: [String]) -> String {
            ""
        }
        
        
    }
    let embeddings: Embeddings
    func encode(sentence: String) async -> [Float]? {
        let e = await embeddings.embedQuery(text: sentence)
        if e.isEmpty {
            print("⚠️\(sentence.prefix(100))")
        }
        return e
    }
    
    
}
public class SimilaritySearchKit: VectorStore {
    let vs: SimilarityIndex
    
    public init(embeddings: Embeddings, autoLoad: Bool = false) {
        self.vs = SimilarityIndex(
            model: LangChainEmbeddingBridge(embeddings: embeddings),
            metric: DotProduct()
        )
        if #available(macOS 13.0, *) {
            if autoLoad {
                let _ = try? vs.loadIndex()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func similaritySearch(query: String, k: Int) async -> [MatchedModel] {
        await vs.search(query, top: k).map{MatchedModel(content: $0.text, similarity: $0.score, metadata: $0.metadata)}
    }
    
    override func addText(text: String, metadata: [String: String]) async {
        await vs.addItem(id: UUID().uuidString, text: text, metadata: metadata)
    }
    
    @available(macOS 13.0, *)
    public func writeToFile() {
        let _ = try? vs.saveIndex()
    }
}
#endif
