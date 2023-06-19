//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/16.
//

import Foundation

public struct PromptTemplate {
    // Schema to represent a prompt for an LLM.
    
    let input_variables: [String]
    // A list of the names of the variables the prompt template expects.
    
    let template: String
    // The prompt template.
    func format(args: [String]) -> String {
        String(format: template, args)
    }
}
