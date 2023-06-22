//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/22.
//

import Foundation

public struct BaseMessage {
    let content: String
    let type: String
}
public protocol BaseMemory {
    func load_memory_variables(inputs: [String: Any]) -> [String: Any]
    
    func save_context(inputs: [String: Any], outputs: [String: String])
    
    func clear()
}

public class BaseChatMessageHistory {
    public func add_user_message(message: String) {
        self.add_message(message: BaseMessage(content: message, type: "human"))
    }
    
    public func add_ai_message(message: String) {
        self.add_message(message: BaseMessage(content: message, type: "ai"))
    }
    
    public func add_message(message: BaseMessage) {
        
    }
    
    public func clear() {
        
    }
}
//class BaseMemory(Serializable, ABC):
//    """Base interface for memory in chains."""
//
//    class Config:
//        """Configuration for this pydantic object."""
//
//        arbitrary_types_allowed = True
//
//    @property
//    @abstractmethod
//    def memory_variables(self) -> List[str]:
//        """Input keys this memory class will load dynamically."""
//
//    @abstractmethod
//    def load_memory_variables(self, inputs: Dict[str, Any]) -> Dict[str, Any]:
//        """Return key-value pairs given the text input to the chain.
//
//        If None, return all memories
//        """
//
//    @abstractmethod
//    def save_context(self, inputs: Dict[str, Any], outputs: Dict[str, str]) -> None:
//        """Save the context of this model run to memory."""
//
//    @abstractmethod
//    def clear(self) -> None:
//        """Clear memory contents."""
//
//
//class BaseChatMessageHistory(ABC):
//    """Base interface for chat message history
//    See `ChatMessageHistory` for default implementation.
//    """
//
//    """
//    Example:
//        .. code-block:: python
//
//            class FileChatMessageHistory(BaseChatMessageHistory):
//                storage_path:  str
//                session_id: str
//
//               @property
//               def messages(self):
//                   with open(os.path.join(storage_path, session_id), 'r:utf-8') as f:
//                       messages = json.loads(f.read())
//                    return messages_from_dict(messages)
//
//               def add_message(self, message: BaseMessage) -> None:
//                   messages = self.messages.append(_message_to_dict(message))
//                   with open(os.path.join(storage_path, session_id), 'w') as f:
//                       json.dump(f, messages)
//               
//               def clear(self):
//                   with open(os.path.join(storage_path, session_id), 'w') as f:
//                       f.write("[]")
//    """
//
//    messages: List[BaseMessage]
//
//    def add_user_message(self, message: str) -> None:
//        """Add a user message to the store"""
//        self.add_message(HumanMessage(content=message))
//
//    def add_ai_message(self, message: str) -> None:
//        """Add an AI message to the store"""
//        self.add_message(AIMessage(content=message))
//
//    def add_message(self, message: BaseMessage) -> None:
//        """Add a self-created message to the store"""
//        raise NotImplementedError
//
//    @abstractmethod
//    def clear(self) -> None:
//        """Remove all messages from the store"""
