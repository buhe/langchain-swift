//
//  File.swift
//  
//
//  Created by 顾艳华 on 2/7/24.
//

import Foundation
import SwiftyNotion

public class NotionLoader: BaseLoader {
    
    fileprivate func buildBlocks(_ notion: NotionAPIGateway, withId: String, title: String) async throws -> [Document]{
        let blocks = try await notion.retrieveBlockChildren(withId: withId)
        //        print(content.properties["title"]?.title![0].plainText)
//        print("blocks: \(content)")
        var foundDoc = false
        var content = ""
        var docs = [Document]()
        for block in blocks {
            if block.type == .childPage {
                let blockId = block.id.replacingOccurrences(of: "-", with: "")
//                print("blockId: \(blockId)")
                let title = block.childPage!.title
                let children = try await buildBlocks(notion, withId: blockId, title: title)
                docs.append(contentsOf: children)
            } else {
                //child
                foundDoc = true
                if let c = block.paragraph {
                    for t in c.text {
                        content.append(t.plainText)
                        content.append("\n")
                    }
                }
//                todo
            }
        }
        if foundDoc {
            docs.append(Document(page_content: content, metadata: ["title": title]))
        }
        return docs
    }
    
    public override func _load() async throws -> [Document] {
        
//        let notion = NotionClient(accessKeyProvider: StringAccessKeyProvider(accessKey: "secret_ODO49SlZawEpwsT3Gzfn401iemthmiaeqKIWL1qf6Th"))
//        let pageId = Page.Identifier("dbdaeff6b2954534ae8323d65053df58")
//
//        notion.page(pageId: pageId) {
//            print("page: \($0)")
//        }
        let notion = NotionAPIGateway(secretKey: "secret_ODO49SlZawEpwsT3Gzfn401iemthmiaeqKIWL1qf6Th")
        let pageId = "dbdaeff6b2954534ae8323d65053df58"
        let title = try await notion.retrievePage(withId: pageId)
        let docs = try await buildBlocks(notion, withId: pageId, title: title.properties["title"]?.title?.first?.plainText ?? "")
        
        print("🥰\(docs)")
        print("🍰\(docs.count)")
        return docs
    }
}
