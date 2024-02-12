//
//  File.swift
//  
//
//  Created by 顾艳华 on 2/10/24.
//

import Foundation
import FeedKit

public class RSSLoader: BaseLoader {
    let url: String
    
    public init(url: String, callbacks: [BaseCallbackHandler] = []) {
        self.url = url
        super.init(callbacks: callbacks)
    }
    public override func _load() async throws  -> [Document] {
        let feedURL = URL(string: url)!
        let parser = FeedParser(URL: feedURL)
        let result = parser.parse()
        switch result {
        case .success(let feed):
            
            // Grab the parsed feed directly as an optional rss, atom or json feed object
            switch feed {
            case let .atom(feed):
                print("🌈atom:\(feed)")
                return []// Atom Syndication Format Feed Model
            case let .rss(feed):
                var content = [Document]()
                for f in feed.items ?? [] {
                    content.append(Document(page_content: f.title ?? "", metadata: [:]))
                }
                return content// Really Simple Syndication Feed Model
            case let .json(feed):
                print("🌈json:\(feed)")
                return []// JSON Feed Model
            }
            
            
        case .failure(let error):
            print(error)
            return []
        }
        
    }
}
