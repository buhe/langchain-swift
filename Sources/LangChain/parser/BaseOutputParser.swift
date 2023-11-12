//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/21.
//

import Foundation
import SwiftyJSON

public struct AgentAction{
    let action: String
    let input: String
    let log: String
}
public struct AgentFinish {
    let final: String
}

public enum Parsed {
    case action(AgentAction)
    case finish(AgentFinish)
    case error
    case unimplemented
    case nothing
    case str(String)
    case list([String])
    case json(JSON)
    case dict([String: String])
    case object(Codable)
    case enumType(Any)
    case date(Date)
}
public protocol BaseOutputParser {
    func parse(text: String) -> Parsed
}

public struct StrOutputParser: BaseOutputParser {
    public init() {}
    public func parse(text: String) -> Parsed {
        Parsed.str(text)
    }
    
    
}
