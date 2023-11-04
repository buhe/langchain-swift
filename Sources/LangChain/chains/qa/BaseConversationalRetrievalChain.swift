//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/3.
//

import Foundation
public class BaseConversationalRetrievalChain: DefaultChain {

    static let _template = """
    Given the following conversation and a follow up question, rephrase the follow up question to be a standalone question, in its original language.

    Chat History:
    {chat_history}
    Follow Up Input: {question}
    Standalone question:
    """
    static let CONDENSE_QUESTION_PROMPT = PromptTemplate(input_variables: ["chat_history", "question"], partial_variable: [:], template: _template)

    let combineChain: BaseCombineDocumentsChain
    let condense_question_chain: LLMChain
    
    init(llm: LLM) {
        self.combineChain = StuffDocumentsChain(llm: llm)
        self.condense_question_chain = LLMChain(llm: llm, prompt: BaseConversationalRetrievalChain.CONDENSE_QUESTION_PROMPT)
        super.init(outputKey: "", inputKey: "")
    }
    func get_docs(question: String) async -> String {
        ""
    }
    public override func _call(args: String) async -> (LLMResult?, Parsed) {
        print("call qa base.")
        // TODO gen new question with chat history
        let new_question = await self.condense_question_chain.predict(args: ["question": args, "chat_history": ""])
        if let new_question = new_question {
            let output = await combineChain.runDict(args: ["docs": await self.get_docs(question: new_question), "question": new_question])
            return (LLMResult(), output)
        } else {
            return (nil, Parsed.error)
        }
    }
}
