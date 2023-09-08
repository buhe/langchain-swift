//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/9/8.
//

import Foundation

public struct EnumOutputParser<T> : BaseOutputParser where T: RawRepresentable ,T: CaseIterable, T.RawValue == String  {
    public init(enumType: T.Type) {
        self.enumType = enumType
    }
    
    let enumType: T.Type
    public func parse(text: String) -> Parsed {
        if let e = T(rawValue: text){
            return Parsed.enumType(e)
        } else {
            return Parsed.str("Parse fail.")
        }
    }
    
    public func get_format_instructions() -> String {
        var all: [String] = []
        for value in T.allCases {
            all.append(value.rawValue)
        }
        return String(format: "Select one of the following options: {%@}", all.joined(separator: ", "))
    }
    
}
