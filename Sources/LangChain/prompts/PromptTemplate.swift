//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/16.
//

import Foundation

public class PromptTemplate {
    // Schema to represent a prompt for an LLM.
    public init(input_variables: [String], partial_variable: [String : String], template: String) {
        self.input_variables = input_variables
        self.partial_variable = partial_variable
        self.template = template
    }
    
    public let input_variables: [String]
    public let partial_variable: [String: String]
    // A list of the names of the variables the prompt template expects.
    
    public let template: String
    // The prompt template.
    public func format(args: [String: String]) -> String {
        var templateCopy = template
        for (k, v) in partial_variable {
            let replace = "{\(k)}"
            templateCopy = templateCopy.replacingOccurrences(of: replace, with: v)
        }
//        assert(args.count == input_variables.count)
//        var argsCopy = args
        for k in input_variables {
            let replace = "{\(k)}"
            let input = args[k]
            if input != nil {
                templateCopy = templateCopy.replacingOccurrences(of: replace, with: input!)
            }
        }
        return templateCopy
    }
    
    public static func from_template(input_variables: [String], partial_variable: [String : String], template: String) -> PromptTemplate {
        PromptTemplate(input_variables: input_variables, partial_variable: partial_variable, template: template)
    }
}

