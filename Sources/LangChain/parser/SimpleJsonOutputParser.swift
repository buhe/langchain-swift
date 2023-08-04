//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/4.
//

import Foundation
import SwiftyJSON

public struct SimpleJsonOutputParser: BaseOutputParser {
    public func parse(text: String) -> Parsed {
        do {
            return Parsed.json(try JSON(data: text.data(using: .utf8)!))
        } catch {
            print("Parse json error: \(text)")
            return Parsed.error
        }
    }
    
    
}
