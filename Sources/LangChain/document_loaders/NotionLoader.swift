//
//  File.swift
//  
//
//  Created by 顾艳华 on 2/7/24.
//

import Foundation
import SwiftyNotion

public class NotionLoader: BaseLoader {
    
    fileprivate func buildBlocks(_ notion: NotionAPIGateway, withId: String) async throws {
        let content = try await notion.retrieveBlockChildren(withId: withId)
        //        print(content.properties["title"]?.title![0].plainText)
        print("blocks: \(content)")
        for block in content {
            if block.hasChildren {
                let blockId = block.id.replacingOccurrences(of: "-", with: "")
                print("blockId: \(blockId)")
                try await buildBlocks(notion, withId: blockId)
            } else {
                //add document
            }
        }
    }
    
    public override func _load() async throws -> [Document] {
        
//        let notion = NotionClient(accessKeyProvider: StringAccessKeyProvider(accessKey: "secret_ODO49SlZawEpwsT3Gzfn401iemthmiaeqKIWL1qf6Th"))
//        let pageId = Page.Identifier("dbdaeff6b2954534ae8323d65053df58")
//
//        notion.page(pageId: pageId) {
//            print("page: \($0)")
//        }
        var docs = [Document]()
        let notion = NotionAPIGateway(secretKey: "secret_ODO49SlZawEpwsT3Gzfn401iemthmiaeqKIWL1qf6Th")
        try await buildBlocks(notion, withId: "dbdaeff6b2954534ae8323d65053df58")
        return []
    }
}
