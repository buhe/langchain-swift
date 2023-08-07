//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/7.
//

import Foundation
public struct RouterOutputParser: BaseOutputParser {
    let default_destination = "DEFAULT"
//    next_inputs_type: Type = str
//    let next_inputs_inner_key = "input"
    public func parse(text: String) -> Parsed {
        print("router text: \(text)")
//        try:
//                   expected_keys = ["destination", "next_inputs"]
//                   parsed = parse_and_check_json_markdown(text, expected_keys)
//                   if not isinstance(parsed["destination"], str):
//                       raise ValueError("Expected 'destination' to be a string.")
//                   if not isinstance(parsed["next_inputs"], self.next_inputs_type):
//                       raise ValueError(
//                           f"Expected 'next_inputs' to be {self.next_inputs_type}."
//                       )
//                   parsed["next_inputs"] = {self.next_inputs_inner_key: parsed["next_inputs"]}
//                   if (
//                       parsed["destination"].strip().lower()
//                       == self.default_destination.lower()
//                   ):
//                       parsed["destination"] = None
//                   else:
//                       parsed["destination"] = parsed["destination"].strip()
//                   return parsed
//               except Exception as e:
//                   raise OutputParserException(
//                       f"Parsing text\n{text}\n raised following error:\n{e}"
//                   )
        let expected_keys = ["destination", "next_inputs"]
        return Parsed.dict([:])
    }
    
    
}
