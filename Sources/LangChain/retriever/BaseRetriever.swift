//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/1.
//

import Foundation

public class BaseRetriever {
    public func _get_relevant_documents(query: String) async throws  -> [Document] {
        []
    }
    
    public func get_relevant_documents(query: String) async -> [Document] {
        do {
            return try await self._get_relevant_documents(query: query)
        } catch {
            print("get_relevant_documents error \(error.localizedDescription)")
            return []
        }
    }
}
