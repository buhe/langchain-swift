//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/3.
//

import Foundation
public class ConversationalRetrievalChain: BaseConversationalRetrievalChain {
    let retriver: BaseRetriever
    public init(retriver: BaseRetriever, llm: LLM) {
        self.retriver = retriver
        super.init(llm: llm)
    }
    
    override func get_docs(question: String) async -> String {
        let docs = await retriver.get_relevant_documents(query: question)
        let docsStr = docs.map{$0.page_content}.joined(separator: "\n\n")
        return docsStr
    }
}
