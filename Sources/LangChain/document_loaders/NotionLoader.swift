//
//  File.swift
//  
//
//  Created by 顾艳华 on 2/7/24.
//

import Foundation
import SwiftyNotion

public class NotionLoader: BaseLoader {
    
    public override func _load() async throws -> [Document] {
        
//        let notion = NotionClient(accessKeyProvider: StringAccessKeyProvider(accessKey: "secret_ODO49SlZawEpwsT3Gzfn401iemthmiaeqKIWL1qf6Th"))
//        let pageId = Page.Identifier("dbdaeff6b2954534ae8323d65053df58")
//
//        notion.page(pageId: pageId) {
//            print("page: \($0)")
//        }
        let notion = NotionAPIGateway(secretKey: "secret_ODO49SlZawEpwsT3Gzfn401iemthmiaeqKIWL1qf6Th")
        let content = try await notion.retrieveBlockChildren(withId: "b3463f9ddbf34788b9720f6ff2fd0603")
//        print(content.properties["title"]?.title![0].plainText)
        print("block: \(content)")
        return []
    }
}
