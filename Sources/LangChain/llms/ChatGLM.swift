//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/30.
//

import Foundation

public struct ChatGLM: LLM{
    public func send(text: String, stops: [String]) async -> String {
        return await api.call(text: text)
    }
    
    let api: ChatGLMAPIWrapper
    
    public init(model: ChatGLMModel = ChatGLMModel.chatglm_std) {
        api = ChatGLMAPIWrapper(model: model)
    }
    
}
