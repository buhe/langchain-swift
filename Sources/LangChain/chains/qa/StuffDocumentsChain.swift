//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/4.
//

import Foundation

public class StuffDocumentsChain: BaseCombineDocumentsChain {
    
    static let prompt_template = """
    Use the following pieces of context to answer the question at the end. If you don't know the answer, just say that you don't know, don't try to make up an answer.
    
    {context}

    Question: {question}
    Helpful Answer:
"""
    static let PROMPT = PromptTemplate(input_variables: ["context", "question"], partial_variable: [:], template: prompt_template)

    let llm_chain: LLMChain
    init(llm: LLM) {
        self.llm_chain = LLMChain(llm: llm, prompt: StuffDocumentsChain.PROMPT)
        super.init(outputKey: "input", inputKey: "output")
    }
    public override func combine_docs(docs: String, question: String) async -> String? {
        return await llm_chain.predict(args: ["question": question, "context": docs])
    }

}
