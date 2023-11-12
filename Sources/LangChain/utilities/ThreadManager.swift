//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/10.
//

import Foundation
import NIOPosix
import NIOCore

struct ThreadManager {
    static let thread: MultiThreadedEventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
}
