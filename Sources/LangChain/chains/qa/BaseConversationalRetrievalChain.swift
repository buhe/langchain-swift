//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/3.
//

import Foundation
public class BaseConversationalRetrievalChain: DefaultChain {
    public override func _call(args: String) async -> (LLMResult?, Parsed) {
        print("call qa base.")
        return (LLMResult(), Parsed.unimplemented)
    }
}
