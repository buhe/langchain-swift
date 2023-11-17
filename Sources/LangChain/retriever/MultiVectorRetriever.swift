//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/17.
//

import Foundation
public class MultiVectorRetriever: BaseRetriever {
    let vectorstore: VectorStore
    let docstore: BaseStore
    let id_key = "doc_id"
    
    public init(vectorstore: VectorStore, docstore: BaseStore) {
        self.vectorstore = vectorstore
        self.docstore = docstore
    }
    
    public override func _get_relevant_documents(query: String) async throws  -> [Document] {
        []
    }
}
