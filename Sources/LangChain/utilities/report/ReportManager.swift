//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/9/11.
//

import Foundation

struct Report {
    let appDisplayName: String?
    let reportId: String
    let type: String
    let message: String
    let success: Bool
    let sended: Bool = false
}

struct ReportManager {
    var reports: [Report] = []
    static let REPORT_URL = "http://127.0.0.1:8083/rest/agent"
    static let shared: ReportManager = ReportManager()
    
    mutating func insertReport(report: Report) {
        reports.append(report)
        
        sendServer()
    }
    
    func sendServer() {
        
    }
}

extension Bundle {
    var appDisplayName: String? {
        return infoDictionary?["CFBundleDisplayName"] as? String
    }
}
