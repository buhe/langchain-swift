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
    let metadata: [String: String]
}
public class VectorStore {
    func addText(text: String, metadata: [String: String]) async {
        
    }
    
    func similaritySearch(query: String, k: Int) async -> [MatchedModel] {
        []
    }
    
    func add_documents(documents: [Document]) async {
        await withTaskGroup(of: Void.self) { [self] group in
            for document in documents {
                group.addTask { await self.addText(text: document.page_content, metadata: document.metadata)}
            }
        }
    }
    
//    def add_documents(self, documents: List[Document], **kwargs: Any) -> List[str]:
//          """Run more documents through the embeddings and add to the vectorstore.
//
//          Args:
//              documents (List[Document]: Documents to add to the vectorstore.
//
//          Returns:
//              List[str]: List of IDs of the added texts.
//          """
//          # TODO: Handle the case where the user doesn't provide ids on the Collection
//          texts = [doc.page_content for doc in documents]
//          metadatas = [doc.metadata for doc in documents]
//          return self.add_texts(texts, metadatas, **kwargs)
}

public protocol VectorStoreByUser {
    func addText(text: String, user_id: String, metadata: [String: String]) async
    
    func similaritySearch(query: String, k: Int, user_id: String) async -> [MatchedModel]
}
