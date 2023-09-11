//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/9/11.
//

import Foundation

struct Report {
    
    let sended: Bool = false
}

struct ReportManager {
    var reports: [Report] = []
    
    static let shared: ReportManager = ReportManager()
    
    mutating func insertReport(report: Report) {
        reports.append(report)
    }
    
    func sendServer() {
        
    }
}
