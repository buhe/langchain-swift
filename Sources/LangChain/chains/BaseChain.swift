//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/19.
//

import Foundation

public class DefaultChain: Chain {
    public init(memory: BaseMemory? = nil, outputKey: String? = nil, callbacks: [BaseCallbackHandler] = []) {
        self.memory = memory
        self.outputKey = outputKey
        self.callbacks = callbacks
    }
    let memory: BaseMemory?
    let outputKey: String?
    let callbacks: [BaseCallbackHandler]
    public func call(args: String) async throws -> LLMResult {
        print("call base.")
        return LLMResult()
    }
    
    func callEnd() {
        for callback in self.callbacks {
            do {
                try callback.on_chain_end()
            } catch {
                print("call chain end callback errer: \(error)")
            }
        }
    }
    // This interface alreadly return 'LLMReult', ensure 'run' method has stream style.
    public func run(args: String) async -> LLMResult {
        do {
            return try await self.call(args: args)
        } catch {
            print(error)
            return LLMResult()
        }
    }
    
    func prep_outputs(inputs: [String: String], outputs: [String: String]) -> [String: String] {
        if self.memory != nil {
            self.memory!.save_context(inputs: inputs, outputs: outputs)
        }
        var m = inputs
        outputs.forEach { (key, value) in
            m[key] = value
        }
        return m
    }
    
    func prep_inputs(inputs: [String: String]) -> [String: String] {
        if self.memory != nil {
            var external_context = Dictionary(uniqueKeysWithValues: self.memory!.load_memory_variables(inputs: inputs).map {(key, value) in return (key, value.joined(separator: "\n"))})
            //        print("ctx: \(external_context)")
            inputs.forEach { (key, value) in
                external_context[key] = value
            }
            return external_context
        } else {
            return inputs
        }
    }
    
//    def prep_outputs(
//         self,
//         inputs: Dict[str, str],
//         outputs: Dict[str, str],
//         return_only_outputs: bool = False,
//     ) -> Dict[str, str]:
//         """Validate and prep outputs."""
//         self._validate_outputs(outputs)
//         if self.memory is not None:
//             self.memory.save_context(inputs, outputs)
//         if return_only_outputs:
//             return outputs
//         else:
//             return {**inputs, **outputs}
//
//     def prep_inputs(self, inputs: Union[Dict[str, Any], Any]) -> Dict[str, str]:
//         """Validate and prep inputs."""
//         if not isinstance(inputs, dict):
//             _input_keys = set(self.input_keys)
//             if self.memory is not None:
//                 # If there are multiple input keys, but some get set by memory so that
//                 # only one is not set, we can still figure out which key it is.
//                 _input_keys = _input_keys.difference(self.memory.memory_variables)
//             if len(_input_keys) != 1:
//                 raise ValueError(
//                     f"A single string input was passed in, but this chain expects "
//                     f"multiple inputs ({_input_keys}). When a chain expects "
//                     f"multiple inputs, please call it by passing in a dictionary, "
//                     "eg `chain({'foo': 1, 'bar': 2})`"
//                 )
//             inputs = {list(_input_keys)[0]: inputs}
//         if self.memory is not None:
//             external_context = self.memory.load_memory_variables(inputs)
//             inputs = dict(inputs, **external_context)
//         self._validate_inputs(inputs)
//         return inputs
}

public protocol Chain {
    func call(args: String) async throws -> LLMResult
}
