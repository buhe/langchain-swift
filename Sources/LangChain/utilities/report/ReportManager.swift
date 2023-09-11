//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/9/11.
//

import Foundation

struct Report {
    let appDisplayName: String?
    let id: String
    let sended: Bool = false
}

struct ReportManager {
    var reports: [Report] = []
    
    static let shared: ReportManager = ReportManager()
    
    func fetchIDIfExist() -> String {
        let id = UUID().uuidString
        // TODO: save env.txt on dev env
        return id
    }
    mutating func insertReport(report: Report) {
        reports.append(report)
    }
    
    func sendServer() {
        
    }
}

extension Bundle {
    var appDisplayName: String? {
        return infoDictionary?["CFBundleDisplayName"] as? String
    }
}
