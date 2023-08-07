//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/16.
//

import Foundation

public struct PromptTemplate {
    // Schema to represent a prompt for an LLM.
    public init(input_variables: [String], template: String, output_parser: BaseOutputParser? = nil) {
        self.input_variables = input_variables
        self.template = template
        self.output_parser = output_parser
    }
    
    public let input_variables: [String]
    // A list of the names of the variables the prompt template expects.
    
    public let template: String
    
    public let output_parser: BaseOutputParser?
    // The prompt template.
    public func format(args: [String]) -> String {
        String(format: template, arguments: args)
    }
}
