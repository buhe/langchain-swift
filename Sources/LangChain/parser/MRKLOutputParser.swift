//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/21.
//

import Foundation

public struct MRKLOutputParser: BaseOutputParse {
    public init() {}
    public func parse(text: String) -> ActionStep {
//        print(text)
        if text.contains(FINAL_ANSWER_ACTION) {
            return ActionStep.finish(AgentFinish(final: text.components(separatedBy: FINAL_ANSWER_ACTION)[1]))
        }
        let pattern = "Action\\s*:[\\s]*(.*)[\\s]*Action\\s*Input\\s*:[\\s]*(.*)"
        let regex = try! NSRegularExpression(pattern: pattern)
        
        if let match = regex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) {
            
            let firstCaptureGroup = Range(match.range(at: 1), in: text).map { String(text[$0]) }
//            print(firstCaptureGroup!)
            
            
            let secondCaptureGroup = Range(match.range(at: 2), in: text).map { String(text[$0]) }
//            print(secondCaptureGroup!)
            return ActionStep.action(AgentAction(action: firstCaptureGroup!, input: secondCaptureGroup!, log: text))
        } else {
            return ActionStep.error
        }
    }
}
