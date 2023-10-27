//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/7/19.
//
import SwiftSoup
import Foundation

public class HtmlLoader: BaseLoader {
    let html: String
    let url: String
    public init(html: String, url: String, callbacks: [BaseCallbackHandler] = []) {
        self.html = html
        self.url = url
        super.init(callbacks: callbacks)
    }
    
    public override func _load() async throws -> [Document] {
        do {
            let doc: SwiftSoup.Document = try SwiftSoup.parse(html)
            let text = try doc.text()
            let title = findTitle(doc: doc)
            let thumbnail = findImage(text: html, doc: doc)
            let metadata: [String: String] = ["url": url, "title": title, "thumbnail": thumbnail]
            return [Document(page_content: text, metadata: metadata)]
        } catch Exception.Error( _, let message) {
            print("Get body error " + message)
            throw LangChainError.LoaderError("Parse html fail with \(message)")
        } catch {
            print("Get body error \(error)")
            throw LangChainError.LoaderError("Parse html fail with \(error)")
        }
    }
    func findTitle(doc: SwiftSoup.Document) -> String {
        var title = ""
        do {
            //try get html -> header -> <meta property="twitter:title"
            let titleOrNil = try doc.head()?.select("meta[property=twitter:title]").attr("content")
            if titleOrNil != nil {
                title = titleOrNil!
            }
            
            if title.isEmpty {
                title = try doc.title()
            }
        } catch {
            print("Get title error \(error)")
        }
        return title
    }
    func findImage(text: String, doc: SwiftSoup.Document) -> String {
        // First, try get html -> header -> <meta property="twitter:image"
        // Second, try string match.
        let pattern = "(http|https)://[\\S]+?\\.(jpg|jpeg|png|gif)"

        do {
//            print(text)
            var thumbnail = ""
            let thumbnailOrNil = try doc.head()?.select("meta[property=twitter:image]").attr("content")
            if thumbnailOrNil != nil {
                thumbnail = thumbnailOrNil!
            }
            if thumbnail.isEmpty {
                let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
                if !matches.isEmpty {
                   thumbnail = String(text[Range(matches.first!.range, in: text)!])
                }
            }
            return thumbnail
        } catch {
            print("Error: \(error.localizedDescription)")
            return ""
        }
    }
    
    override func type() -> String {
        "Html"
    }
}
