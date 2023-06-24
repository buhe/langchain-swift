//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/24.
//

import Foundation

public class TextSplitter {
    let _chunk_size: Int
    let _chunk_overlap: Int
    public init(_chunk_size: Int, _chunk_overlap: Int) {
        self._chunk_size = _chunk_size
        self._chunk_overlap = _chunk_overlap
    }
    func _split_text_with_regex(text: String) -> [String] {
        text.components(separatedBy: "\n\n")
    }
    
    func _join_docs(docs: [String]) -> String {
        let text = docs.joined()
        return text
    }
    
    func _merge_splits(splits: [String]) -> [String] {
        // We now want to combine these smaller pieces into medium size
        // chunks to send to the LLM.
        
        var docs: [String] = []
        var current_doc: [String] = []
        var total = 0
        for d in splits {
            let _len = d.count
            if total + _len > self._chunk_size {
                if total > self._chunk_size {
                    print(
                        """
                        Created a chunk of size \(total),
                        which is longer than the specified \(self._chunk_size)
                        """
                    )
                }
                if current_doc.count > 0 {
                    let doc = self._join_docs(docs: current_doc)
                    
                    docs.append(doc)
                    // Keep on popping if:
                    // - we have a larger chunk than in the chunk overlap
                    // - or if we still have any chunks and the length is long
                    while total > self._chunk_overlap || ( total + _len > self._chunk_size && total > 0) {
                        total -= current_doc[0].count
                        current_doc.removeFirst()
                    }
                    
                }
            }
            current_doc.append(d)
            total += _len
        }
        let doc = self._join_docs(docs: current_doc)
        
        docs.append(doc)
        return docs
    }
}
    
class CharacterTextSplitter: TextSplitter {
    public func split_text(text: String) -> [String] {
        let splits = _split_text_with_regex(text: text)
        //        _separator = "" if self._keep_separator else self._separator
        return self._merge_splits(splits: splits)
    }
}
//class BaseDocumentTransformer(ABC):
//    """Base interface for transforming documents."""
//
//    @abstractmethod
//    def transform_documents(
//        self, documents: Sequence[Document], **kwargs: Any
//    ) -> Sequence[Document]:
//        """Transform a list of documents."""
//
//    @abstractmethod
//    async def atransform_documents(
//        self, documents: Sequence[Document], **kwargs: Any
//    ) -> Sequence[Document]:
//        """Asynchronously transform a list of documents."""

//class TextSplitter(BaseDocumentTransformer, ABC):
//    """Interface for splitting text into chunks."""
//
//    def __init__(
//        self,
//        chunk_size: int = 4000,
//        chunk_overlap: int = 200,
//        length_function: Callable[[str], int] = len,
//        keep_separator: bool = False,
//        add_start_index: bool = False,
//    ) -> None:
//        """Create a new TextSplitter.
//
//        Args:
//            chunk_size: Maximum size of chunks to return
//            chunk_overlap: Overlap in characters between chunks
//            length_function: Function that measures the length of given chunks
//            keep_separator: Whether or not to keep the separator in the chunks
//            add_start_index: If `True`, includes chunk's start index in metadata
//        """
//        if chunk_overlap > chunk_size:
//            raise ValueError(
//                f"Got a larger chunk overlap ({chunk_overlap}) than chunk size "
//                f"({chunk_size}), should be smaller."
//            )
//        self._chunk_size = chunk_size
//        self._chunk_overlap = chunk_overlap
//        self._length_function = length_function
//        self._keep_separator = keep_separator
//        self._add_start_index = add_start_index
//
//    @abstractmethod
//    def split_text(self, text: str) -> List[str]:
//        """Split text into multiple components."""
//
//    def create_documents(
//        self, texts: List[str], metadatas: Optional[List[dict]] = None
//    ) -> List[Document]:
//        """Create documents from a list of texts."""
//        _metadatas = metadatas or [{}] * len(texts)
//        documents = []
//        for i, text in enumerate(texts):
//            index = -1
//            for chunk in self.split_text(text):
//                metadata = copy.deepcopy(_metadatas[i])
//                if self._add_start_index:
//                    index = text.find(chunk, index + 1)
//                    metadata["start_index"] = index
//                new_doc = Document(page_content=chunk, metadata=metadata)
//                documents.append(new_doc)
//        return documents
//
//    def split_documents(self, documents: Iterable[Document]) -> List[Document]:
//        """Split documents."""
//        texts, metadatas = [], []
//        for doc in documents:
//            texts.append(doc.page_content)
//            metadatas.append(doc.metadata)
//        return self.create_documents(texts, metadatas=metadatas)
//
//    def _join_docs(self, docs: List[str], separator: str) -> Optional[str]:
//        text = separator.join(docs)
//        text = text.strip()
//        if text == "":
//            return None
//        else:
//            return text
//
//    def _merge_splits(self, splits: Iterable[str], separator: str) -> List[str]:
//        # We now want to combine these smaller pieces into medium size
//        # chunks to send to the LLM.
//        separator_len = self._length_function(separator)
//
//        docs = []
//        current_doc: List[str] = []
//        total = 0
//        for d in splits:
//            _len = self._length_function(d)
//            if (
//                total + _len + (separator_len if len(current_doc) > 0 else 0)
//                > self._chunk_size
//            ):
//                if total > self._chunk_size:
//                    logger.warning(
//                        f"Created a chunk of size {total}, "
//                        f"which is longer than the specified {self._chunk_size}"
//                    )
//                if len(current_doc) > 0:
//                    doc = self._join_docs(current_doc, separator)
//                    if doc is not None:
//                        docs.append(doc)
//                    # Keep on popping if:
//                    # - we have a larger chunk than in the chunk overlap
//                    # - or if we still have any chunks and the length is long
//                    while total > self._chunk_overlap or (
//                        total + _len + (separator_len if len(current_doc) > 0 else 0)
//                        > self._chunk_size
//                        and total > 0
//                    ):
//                        total -= self._length_function(current_doc[0]) + (
//                            separator_len if len(current_doc) > 1 else 0
//                        )
//                        current_doc = current_doc[1:]
//            current_doc.append(d)
//            total += _len + (separator_len if len(current_doc) > 1 else 0)
//        doc = self._join_docs(current_doc, separator)
//        if doc is not None:
//            docs.append(doc)
//        return docs
//
//    @classmethod
//    def from_huggingface_tokenizer(cls, tokenizer: Any, **kwargs: Any) -> TextSplitter:
//        """Text splitter that uses HuggingFace tokenizer to count length."""
//        try:
//            from transformers import PreTrainedTokenizerBase
//
//            if not isinstance(tokenizer, PreTrainedTokenizerBase):
//                raise ValueError(
//                    "Tokenizer received was not an instance of PreTrainedTokenizerBase"
//                )
//
//            def _huggingface_tokenizer_length(text: str) -> int:
//                return len(tokenizer.encode(text))
//
//        except ImportError:
//            raise ValueError(
//                "Could not import transformers python package. "
//                "Please install it with `pip install transformers`."
//            )
//        return cls(length_function=_huggingface_tokenizer_length, **kwargs)
//
//    @classmethod
//    def from_tiktoken_encoder(
//        cls: Type[TS],
//        encoding_name: str = "gpt2",
//        model_name: Optional[str] = None,
//        allowed_special: Union[Literal["all"], AbstractSet[str]] = set(),
//        disallowed_special: Union[Literal["all"], Collection[str]] = "all",
//        **kwargs: Any,
//    ) -> TS:
//        """Text splitter that uses tiktoken encoder to count length."""
//        try:
//            import tiktoken
//        except ImportError:
//            raise ImportError(
//                "Could not import tiktoken python package. "
//                "This is needed in order to calculate max_tokens_for_prompt. "
//                "Please install it with `pip install tiktoken`."
//            )
//
//        if model_name is not None:
//            enc = tiktoken.encoding_for_model(model_name)
//        else:
//            enc = tiktoken.get_encoding(encoding_name)
//
//        def _tiktoken_encoder(text: str) -> int:
//            return len(
//                enc.encode(
//                    text,
//                    allowed_special=allowed_special,
//                    disallowed_special=disallowed_special,
//                )
//            )
//
//        if issubclass(cls, TokenTextSplitter):
//            extra_kwargs = {
//                "encoding_name": encoding_name,
//                "model_name": model_name,
//                "allowed_special": allowed_special,
//                "disallowed_special": disallowed_special,
//            }
//            kwargs = {**kwargs, **extra_kwargs}
//
//        return cls(length_function=_tiktoken_encoder, **kwargs)
//
//    def transform_documents(
//        self, documents: Sequence[Document], **kwargs: Any
//    ) -> Sequence[Document]:
//        """Transform sequence of documents by splitting them."""
//        return self.split_documents(list(documents))
//
//    async def atransform_documents(
//        self, documents: Sequence[Document], **kwargs: Any
//    ) -> Sequence[Document]:
//        """Asynchronously transform a sequence of documents by splitting them."""
//        raise NotImplementedError
//
//
//class CharacterTextSplitter(TextSplitter):
//    """Implementation of splitting text that looks at characters."""
//
//    def __init__(self, separator: str = "\n\n", **kwargs: Any) -> None:
//        """Create a new TextSplitter."""
//        super().__init__(**kwargs)
//        self._separator = separator
//
//    def split_text(self, text: str) -> List[str]:
//        """Split incoming text and return chunks."""
//        # First we naively split the large input into a bunch of smaller ones.
//        splits = _split_text_with_regex(text, self._separator, self._keep_separator)
//        _separator = "" if self._keep_separator else self._separator
//        return self._merge_splits(splits, _separator)
