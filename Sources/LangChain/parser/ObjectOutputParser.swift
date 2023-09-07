//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/28.
//

import Foundation

public struct ObjectOutputParser<T: Codable>: BaseOutputParser {
    var schema = ""
    public init(demo: T) {
        self.demo = demo
    }
    
    let demo: T
    let PYDANTIC_FORMAT_INSTRUCTIONS = """
    The output should be formatted as a JSON instance that conforms to the JSON schema below.

    As an example, for the schema {title: String,content: String,unit: {num: Int,},}
    the object {"content":"b","title":"a","unit":{"num":1}} is a well-formatted instance of the schema. The object {{"properties": {"content":"b","title":"a","unit":{"num":1}}}} is not well-formatted.

    Here is the output schema:
    %@
"""
    
    public func parse(text: String) -> Parsed {
        let r = try! JSONDecoder().decode(T.self, from: text.data(using: .utf8)!)
        return Parsed.object(r)
    }
    fileprivate func isPrimitive(_ t: String) -> Bool {
        return t == "Int" || t == "String" || t == "Double" || t == "Float" || t == "Bool"
    }
    
    mutating func printStruct(structObject: Any) {
        let mirror = Mirror(reflecting: structObject)
        for (name, value) in mirror.children {
//            guard let name = name else { continue }
            let t = "\(type(of: value))"
//            print("type: \(t)")
            if isPrimitive(t) {
                let s = "\(name!): \(t)"
                schema += "\(s),"
//                print(s)
            } else if t.starts(with: "Array<") {
//                let s = "\(name): ["
                schema += "["
                printStruct(structObject: value)
                schema += "],"
            } else {
                if let name = name {
                    let s = "\(name): {"
                    schema += "\(s)"
                } else {
                    schema += "{"
                }
                
//                print(s)
                
                printStruct(structObject: value)
                schema += "},"
//                print("}")
            }
        }
    }
    public mutating func get_format_instructions() -> String {
//        print("{")
        schema += "{"
        printStruct(structObject: demo)
//        print("}")
        schema += "}"
//        print("schema: \(schema)")
        let i = String(format: PYDANTIC_FORMAT_INSTRUCTIONS, schema)
        //reset
        schema = ""
        return i
    }
    
}
