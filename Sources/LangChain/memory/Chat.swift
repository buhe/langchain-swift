//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/22.
//

import Foundation
public class BaseChatMemory: BaseMemory {
    let chat_memory: ChatMessageHistory = ChatMessageHistory()
    
    public func load_memory_variables(inputs: [String : Any]) -> [String : [String]] {
        [:]
    }
    
    public func save_context(inputs: [String: String], outputs: [String: String]) {
        for (_, input_str) in inputs {
            self.chat_memory.add_user_message(message: input_str)
        }
        for (_, output_str) in outputs {
            self.chat_memory.add_ai_message(message: output_str)
        }
    }
    
    public func clear() {
        
    }
    
    
}

public class ConversationBufferWindowMemory: BaseChatMemory {
    let memory_key = "history"
    let k: Int
    public init(k: Int = 2) {
        self.k = k
    }
    public override func load_memory_variables(inputs: [String: Any]) -> [String: [String]] {
        // Return history buffer.
        
        let buffer = self.chat_memory.messages.suffix(k)

        let bufferString = buffer.map{ "\($0.type): \($0.content)" }
        return [self.memory_key: bufferString]
    }
}

public class ChatMessageHistory: BaseChatMessageHistory {
    public var messages: [BaseMessage] = []
    
    public override func add_message(message: BaseMessage) {
        //        """Add a self-created message to the store"""
        self.messages.append(message)
    }
    
    public override func clear(){
        self.messages = []
    }
}
//
//class ChatMessageHistory(BaseChatMessageHistory, BaseModel):
//    messages: List[BaseMessage] = []
//
//    def add_message(self, message: BaseMessage) -> None:
//        """Add a self-created message to the store"""
//        self.messages.append(message)
//
//    def clear(self) -> None:
//        self.messages = []

//class BaseChatMemory(BaseMemory, ABC):
//    chat_memory: BaseChatMessageHistory = Field(default_factory=ChatMessageHistory)
//    output_key: Optional[str] = None
//    input_key: Optional[str] = None
//    return_messages: bool = False
//
//    def _get_input_output(
//        self, inputs: Dict[str, Any], outputs: Dict[str, str]
//    ) -> Tuple[str, str]:
//        if self.input_key is None:
//            prompt_input_key = get_prompt_input_key(inputs, self.memory_variables)
//        else:
//            prompt_input_key = self.input_key
//        if self.output_key is None:
//            if len(outputs) != 1:
//                raise ValueError(f"One output key expected, got {outputs.keys()}")
//            output_key = list(outputs.keys())[0]
//        else:
//            output_key = self.output_key
//        return inputs[prompt_input_key], outputs[output_key]
//
//    def save_context(self, inputs: Dict[str, Any], outputs: Dict[str, str]) -> None:
//        """Save context from this conversation to buffer."""
//        input_str, output_str = self._get_input_output(inputs, outputs)
//        self.chat_memory.add_user_message(input_str)
//        self.chat_memory.add_ai_message(output_str)
//
//    def clear(self) -> None:
//        """Clear memory contents."""
//        self.chat_memory.clear()
//            
//
//            class ChatMessageHistory(BaseChatMessageHistory, BaseModel):
//                messages: List[BaseMessage] = []
//
//                def add_message(self, message: BaseMessage) -> None:
//                    """Add a self-created message to the store"""
//                    self.messages.append(message)
//
//                def clear(self) -> None:
//                    self.messages = []
