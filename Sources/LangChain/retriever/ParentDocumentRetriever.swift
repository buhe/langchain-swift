//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/17.
//

import Foundation
public class ParentDocumentRetriever: MultiVectorRetriever {
    init(child_splitter: TextSplitter, parent_splitter: TextSplitter, vectorstore: VectorStore, docstore: BaseStore) {
        self.child_splitter = child_splitter
        self.parent_splitter = parent_splitter
        super.init(vectorstore: vectorstore, docstore: docstore)
    }
    let child_splitter: TextSplitter
    // The text splitter to use to create child documents."""

    
    let parent_splitter: TextSplitter
    //The text splitter to use to create parent documents.
    //If none, then the parent documents will be the raw documents passed in.
    func add_documents(documents: [Document]) {
        let parent_documents = self.parent_splitter.split_documents(documents)
        let doc_ids = documents.map{_ in UUID().uuidString}
        
        var docs: [Document] = []
        var full_docs:[(String, String)] = []
        for i in 0..<parent_documents.count {
            let doc = parent_documents[i]
            let _id = doc_ids[i]
            let sub_docs = self.child_splitter.split_documents([doc])
            for _doc in sub_docs{
                _doc.metadata[self.id_key] = _id
            }
            docs.append(contentsOf: sub_docs)
            full_docs.append((_id, doc.page_content))
        }
        
        self.vectorstore.add_documents(docs)
        self.docstore.mset(kvpairs: full_docs)
    }
//    def add_documents(
//        self,
//        documents: List[Document],
//        ids: Optional[List[str]] = None,
//        add_to_docstore: bool = True,
//    ) -> None:
//        """Adds documents to the docstore and vectorstores.
//
//        Args:
//            documents: List of documents to add
//            ids: Optional list of ids for documents. If provided should be the same
//                length as the list of documents. Can provided if parent documents
//                are already in the document store and you don't want to re-add
//                to the docstore. If not provided, random UUIDs will be used as
//                ids.
//            add_to_docstore: Boolean of whether to add documents to docstore.
//                This can be false if and only if `ids` are provided. You may want
//                to set this to False if the documents are already in the docstore
//                and you don't want to re-add them.
//        """
//        if self.parent_splitter is not None:
//            documents = self.parent_splitter.split_documents(documents)
//        if ids is None:
//            doc_ids = [str(uuid.uuid4()) for _ in documents]
//            if not add_to_docstore:
//                raise ValueError(
//                    "If ids are not passed in, `add_to_docstore` MUST be True"
//                )
//        else:
//            if len(documents) != len(ids):
//                raise ValueError(
//                    "Got uneven list of documents and ids. "
//                    "If `ids` is provided, should be same length as `documents`."
//                )
//            doc_ids = ids
//
//        docs = []
//        full_docs = []
//        for i, doc in enumerate(documents):
//            _id = doc_ids[i]
//            sub_docs = self.child_splitter.split_documents([doc])
//            for _doc in sub_docs:
//                _doc.metadata[self.id_key] = _id
//            docs.extend(sub_docs)
//            full_docs.append((_id, doc))
//        self.vectorstore.add_documents(docs)
//        if add_to_docstore:
//            self.docstore.mset(full_docs)
}
