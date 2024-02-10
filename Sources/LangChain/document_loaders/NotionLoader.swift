//
//  File.swift
//  
//
//  Created by 顾艳华 on 2/7/24.
//

import Foundation
import SwiftyNotion

public class NotionLoader: BaseLoader {
    public override init(callbacks: [BaseCallbackHandler] = []) {
        super.init(callbacks: callbacks)
    }
    fileprivate func appendText(prefix: String, _ content: inout String, _ t: NotionRichText) {
        content.append(prefix + t.plainText)
        content.append("\n")
    }
    
    fileprivate func forText(prefix: String, _ text: [NotionRichText], _ content: inout String) {
        for t in text {
            appendText(prefix: prefix, &content, t)
        }
    }
    
    fileprivate func buildBlocks(_ notion: NotionAPIGateway, withId: String, title: String) async throws -> [Document]{
        let blocks = try await notion.retrieveBlockChildren(withId: withId)
        var foundDoc = false
        var content = ""
        var docs = [Document]()
        for block in blocks {
            if block.type == .childPage {
                let blockId = block.id.replacingOccurrences(of: "-", with: "")
                let title = block.childPage!.title
                let children = try await buildBlocks(notion, withId: blockId, title: title)
                docs.append(contentsOf: children)
            } else {
                //child
                foundDoc = true
                if let c = block.paragraph {
                    forText(prefix: "", c.text, &content)
                }
                if let c = block.code {
                    forText(prefix: "\(c.language) Code: " ,c.text, &content)
                }
                if let c = block.heading1 {
                    forText(prefix: "# ",c.text, &content)
                }
                if let c = block.heading2 {
                    forText(prefix: "## ",c.text, &content)
                }
                if let c = block.heading3 {
                    forText(prefix: "### ",c.text, &content)
                }
                if let c = block.toggle {
                    forText(prefix: "> ",c.text, &content)
                }
                if let c = block.toDo {
                    forText(prefix: "[ ] ",c.text, &content)
                }
                if let c = block.numberedListItem {
                    forText(prefix: "- ",c.text, &content)
                }
                if let c = block.bulletedListItem {
                    forText(prefix: "- ",c.text, &content)
                }
            }
        }
        if foundDoc {
            docs.append(Document(page_content: content, metadata: ["title": title]))
        }
        return docs
    }
    
    public override func _load() async throws -> [Document] {
        let env = Env.loadEnv()
        
        if let apiKey = env["NOTION_API_KEY"], let rootId = env["NOTION_ROOT_NODE_ID"] {
            let notion = NotionAPIGateway(secretKey: apiKey)
            let pageId = rootId
            let title = try await notion.retrievePage(withId: pageId)
            let docs = try await buildBlocks(notion, withId: pageId, title: title.properties["title"]?.title?.first?.plainText ?? "")
            
            print("🥰\(docs)")
            print("🍰\(docs.count)")
            return docs
        } else {
            return []
        }
    }
}
