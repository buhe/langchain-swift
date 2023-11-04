//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/3.
//

import Foundation
public class ConversationalRetrievalChain: BaseConversationalRetrievalChain {
    public override init(retriver: BaseRetriever, combineChain: BaseCombineDocumentsChain) {
        
        super.init(retriver: retriver, combineChain: combineChain)
    }
    
    override func get_docs(question: String) async -> String {
        let docs = await retriver.get_relevant_documents(query: question)
        let docsStr = docs.map{$0.page_content}.joined(separator: "\n\n")
        return docsStr
    }
}
