//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/21.
//

import Foundation
import SwiftyJSON

public struct AgentAction{
    public let action: String
    public let input: String
    public let log: String
    public init(action: String, input: String, log: String) {
        self.action = action
        self.input = input
        self.log = log
    }
}
public struct AgentFinish {
    public let final: String
    public init(final: String) {
        self.final = final
    }
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
