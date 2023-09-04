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
            } catch {
                print("Get title error \(error)")
            }
            if title.isEmpty {
                //try get html -> header -> <meta property="twitter:title"
            }
            let thumbnail = findImage(text: html, doc: doc)
            let metadata: [String: String] = ["url": url, "title": title, "thumbnail": thumbnail]
            return [Document(page_content: text, metadata: metadata)]
        } catch Exception.Error( _, let message) {
            print("Get body error " + message)
            return []
        } catch {
            print("Get body error \(error)")
            return []
        }
    }
    
    func findImage(text: String, doc: SwiftSoup.Document) -> String {
        // First, try get html -> header -> <meta property="twitter:image"
        // Second, try string match.
        let pattern = "(http|https)://[\\S]+?\\.(jpg|jpeg|png|gif)"

        do {
//            print(text)
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            if matches.isEmpty {
                
                
                return ""
            } else {
                return String(text[Range(matches.first!.range, in: text)!])
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return ""
        }
    }
}
