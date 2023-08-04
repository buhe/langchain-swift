//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/4.
//

import Foundation
public struct ListOutputParser: BaseOutputParser {
    public func parse(text: String) -> Parsed {
        Parsed.list(text.components(separatedBy: ","))
    }
    
    
}
