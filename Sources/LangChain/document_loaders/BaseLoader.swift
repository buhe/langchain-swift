//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/24.
//

import Foundation
public struct Document {
    public let page_content: String
    public let metadata: [String: String]
}
public class BaseLoader {
    
    static let LOADER_TYPE_KEY = "loader_type"
    static let LOADER_REQ_ID = "loader_req_id"
    static let LOADER_COST_KEY = "cost"
    
    func load() async -> [Document] {
        let type = type()
        do {
            let docs = try await _load()
            
            return docs
        } catch LangChainError.LoaderError(let cause) {
            print("Catch langchain loader error \(cause)")
            return []
        } catch {
            return []
        }
    }
    
    func _load() async throws -> [Document] {
        []
    }
    
    func type() -> String {
        "Base"
    }
}
//class BaseLoader(ABC):
//    """Interface for loading documents.
//
//    Implementations should implement the lazy-loading method using generators
//    to avoid loading all documents into memory at once.
//
//    The `load` method will remain as is for backwards compatibility, but its
//    implementation should be just `list(self.lazy_load())`.
//    """
//
//    # Sub-classes should implement this method
//    # as return list(self.lazy_load()).
//    # This method returns a List which is materialized in memory.
//    @abstractmethod
//    def load(self) -> List[Document]:
//        """Load data into document objects."""
//
//    def load_and_split(
//        self, text_splitter: Optional[TextSplitter] = None
//    ) -> List[Document]:
//        """Load documents and split into chunks."""
//        if text_splitter is None:
//            _text_splitter: TextSplitter = RecursiveCharacterTextSplitter()
//        else:
//            _text_splitter = text_splitter
//        docs = self.load()
//        return _text_splitter.split_documents(docs)
//
//    # Attention: This method will be upgraded into an abstractmethod once it's
//    #            implemented in all the existing subclasses.
//    def lazy_load(
//        self,
//    ) -> Iterator[Document]:
//        """A lazy loader for document content."""
//        raise NotImplementedError(
//            f"{self.__class__.__name__} does not implement lazy_load()"
//        )
