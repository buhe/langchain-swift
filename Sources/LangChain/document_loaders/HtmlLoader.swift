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
    public init(html: String, url: String) {
        self.html = html
        self.url = url
    }
    
    public func load() async -> [Document] {
        do {
            let doc: SwiftSoup.Document = try SwiftSoup.parse(html)
            let text = try doc.text()
            var title = ""
            do {
                title = try doc.title()
            }catch {
                print("Get title error \(error)")
            }
            let metadata: [String: String] = ["url": url, "title": title]
            return [Document(page_content: text, metadata: metadata)]
        } catch Exception.Error( _, let message) {
            print("Get body error " + message)
            return []
        } catch {
            print("Get body error \(error)")
            return []
        }
    }
    
    
}
