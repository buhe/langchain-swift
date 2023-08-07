//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/7.
//

import Foundation
public class RouterChain {
    public func route() -> Route{
        Route(destination: "", next_inputs: "")
    }
}

public struct Route {
    let destination: String
    let next_inputs: String
}
