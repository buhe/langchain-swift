//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/16.
//

import Foundation

public struct PromptTemplate {
    // Schema to represent a prompt for an LLM.
    public init(input_variables: [String], template: String) {
        self.input_variables = input_variables
        self.template = template
    }
    
    public let input_variables: [String]
    // A list of the names of the variables the prompt template expects.
    
    public let template: String
    // The prompt template.
    public func format(args: [String]) -> String {
        String(format: template, arguments: args)
    }
}
