//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/3.
//

import Foundation
public class BaseConversationalRetrievalChain: DefaultChain {
    let retriver: BaseRetriever
    let combineChain: BaseCombineDocumentsChain
    
    init(retriver: BaseRetriever, combineChain: BaseCombineDocumentsChain) {
        self.retriver = retriver
        self.combineChain = combineChain
        super.init(outputKey: "", inputKey: "")
    }
    func get_docs(question: String) async -> String {
        ""
    }
    public override func _call(args: String) async -> (LLMResult?, Parsed) {
        print("call qa base.")
        let output = await combineChain.runDict(args: ["docs": await self.get_docs(question: args), "question": args])
        return (LLMResult(), output)
    }
}
