//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/21.
//

import Foundation
public protocol BaseOutputParser {
    func parse(text: String) -> ActionStep
}

public struct Nothing: BaseOutputParser {
    public init() {}
    public func parse(text: String) -> ActionStep {
        ActionStep.notParse(text)
    }
    
    
}
