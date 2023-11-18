//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/12.
//

import Foundation
import Supabase

struct SearchVectorParams: Codable {
    let query_embedding: [Float]
    let match_count: Int
}
struct DocModel: Encodable, Decodable {
    let content: String?
    let embedding: [Float]
    let metadata: [String: String]
}

public class Supabase: VectorStore {
    let client: SupabaseClient
    let embeddings: Embeddings
    public init(embeddings: Embeddings) {
        self.embeddings = embeddings
        let env = Env.loadEnv()
        client = SupabaseClient(supabaseURL: URL(string: env["SUPABASE_URL"]!)!, supabaseKey: env["SUPABASE_KEY"]!)
    }
    
    public override func similaritySearch(query: String, k: Int) async -> [MatchedModel] {
        let params = SearchVectorParams(query_embedding: await embeddings.embedQuery(text: query), match_count: k)
        let rpcQuery = client.database.rpc(fn: "match_documents", params: params)

        do {
            let response: [MatchedModel] = try await rpcQuery.execute().value // Where DataModel is the model of the data returned by the function
//            print("### RPC Returned: \(response.first!.content!)")
            return response
           } catch {
               print("### RPC Error: \(error)")
               return []
           }
        
    }
    
    public override func addText(text: String, metadata: [String: String]) async {
        let embedding = await embeddings.embedQuery(text: text)
        let insertData = DocModel(content: text, embedding: embedding, metadata: metadata)
        let query = client.database
            .from("documents")
            .insert(values: insertData,
                    returning: .representation) // you will need to add this to return the added data
//            .select(columns: "id") // specifiy which column names to be returned. Leave it empty for all columns
            .single() // specify you want to return a single value.
        
        do {
            let _: String = try await query.execute().value
//          print("### Save Returned: \(response)")
        } catch {
            print("### Insert Error: \(error)")
        }
    }
}
