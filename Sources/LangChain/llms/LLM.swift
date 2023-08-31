//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/10.
//

import Foundation
// TODO - http outter
public protocol LLM {
    func send(text: String, stops: [String]) async -> LLMResult
}
