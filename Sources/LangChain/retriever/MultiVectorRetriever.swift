//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/17.
//

import Foundation
public class MultiVectorRetriever: BaseRetriever {
    let vectorstore: VectorStore
    let docstore: BaseStore
    let id_key = "doc_id"
    
    public init(vectorstore: VectorStore, docstore: BaseStore) {
        self.vectorstore = vectorstore
        self.docstore = docstore
    }
    
    public override func _get_relevant_documents(query: String) async throws  -> [Document] {
        let sub_docs = await self.vectorstore.similaritySearch(query: query, k: 1)
        var ids: [String] = []
        for d in sub_docs {
            ids.append(d.metadata[self.id_key]!)
        }
        let docs = await self.docstore.mget(keys: ids)
        return docs.map{Document(page_content: $0, metadata: [:])}
    }
    
//    def _get_relevant_documents(
//           self, query: str, *, run_manager: CallbackManagerForRetrieverRun
//       ) -> List[Document]:
//           """Get documents relevant to a query.
//           Args:
//               query: String to find relevant documents for
//               run_manager: The callbacks handler to use
//           Returns:
//               List of relevant documents
//           """
//           sub_docs = self.vectorstore.similarity_search(query, **self.search_kwargs)
//           # We do this to maintain the order of the ids that are returned
//           ids = []
//           for d in sub_docs:
//               if d.metadata[self.id_key] not in ids:
//                   ids.append(d.metadata[self.id_key])
//           docs = self.docstore.mget(ids)
//           return [d for d in docs if d is not None]
}
