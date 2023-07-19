//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/7/19.
//
import SwiftSoup
import Foundation

public struct HtmlLoader: BaseLoader {
    let html: String
    let url: String
    
    public func load() async -> [Document] {
        do {
            let doc: SwiftSoup.Document = try SwiftSoup.parse(html)
            let text = try doc.text()
            var title = ""
            do {
                title = try doc.title()
            }catch {
                print(error)
            }
            let metadata: [String: String] = ["url": url, "title": title]
            return [Document(page_content: text, metadata: metadata)]
        } catch Exception.Error( _, let message) {
            print(message)
            return []
        } catch {
            print("error")
            return []
        }
    }
    
    
}
