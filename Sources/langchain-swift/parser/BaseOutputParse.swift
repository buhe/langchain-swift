//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/21.
//

import Foundation
public protocol BaseOutputParse {
    func parse(text: String) -> ActionStep
}

public struct Nothing: BaseOutputParse {
    public init() {}
    public func parse(text: String) -> ActionStep {
        ActionStep.pass(text)
    }
    
    
}
