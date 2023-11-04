//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/19.
//

import Foundation

public class DefaultChain {
    static let CHAIN_REQ_ID_KEY = "chain_req_id"
    static let CHAIN_COST_KEY = "cost"
    public init(memory: BaseMemory? = nil, outputKey: String, inputKey: String, callbacks: [BaseCallbackHandler] = []) {
        self.memory = memory
        self.outputKey = outputKey
        self.inputKey = inputKey
        var cbs: [BaseCallbackHandler] = callbacks
        if Env.addTraceCallbak() && !cbs.contains(where: { item in item is TraceCallbackHandler}) {
            cbs.append(TraceCallbackHandler())
        }
//        assert(cbs.count == 1)
        self.callbacks = cbs
    }
    let memory: BaseMemory?
    let inputKey: String
    let outputKey: String
    let callbacks: [BaseCallbackHandler]
    public func _call(args: String) async -> (LLMResult?, Parsed) {
        print("call base.")
        return (LLMResult(), Parsed.unimplemented)
    }

    func callEnd(output: String, reqId: String, cost: Double) {
        for callback in self.callbacks {
            do {
                try callback.on_chain_end(output: output, metadata: [DefaultChain.CHAIN_REQ_ID_KEY: reqId, DefaultChain.CHAIN_COST_KEY: "\(cost)"])
            } catch {
                print("call chain end callback errer: \(error)")
            }
        }
    }
    
    func callStart(prompt: String, reqId: String) {
        for callback in self.callbacks {
            do {
                try callback.on_chain_start(prompts: prompt, metadata: [DefaultChain.CHAIN_REQ_ID_KEY: reqId])
            } catch {
                print("call chain end callback errer: \(error)")
            }
        }
    }
    
    func callCatch(error: Error, reqId: String, cost: Double) {
        for callback in self.callbacks {
            do {
                try callback.on_chain_error(error: error, metadata: [DefaultChain.CHAIN_REQ_ID_KEY: reqId, DefaultChain.CHAIN_COST_KEY: "\(cost)"])
            } catch {
                print("call LLM start callback errer: \(error)")
            }
        }
    }
    
    // This interface alreadly return 'LLMReult', ensure 'run' method has stream style.
    public func run(args: String) async -> Parsed {
        let _ = prep_inputs(inputs: [inputKey: args])
        // = Langchain's run + __call__
        let reqId = UUID().uuidString
        var cost = 0.0
        let now = Date.now.timeIntervalSince1970
        
            callStart(prompt: args, reqId: reqId)
        let outputs = await self._call(args: args)
        if let llmResult = outputs.0 {
            cost = Date.now.timeIntervalSince1970 - now
            //call end trace
            //            if !outputs.0.stream {
            callEnd(output: llmResult.llm_output!, reqId: reqId, cost: cost)
            //            } else {
            //                callEnd(output: "[LLM is streamable]", reqId: reqId, cost: cost)
            //            }
            let _ = prep_outputs(inputs: [inputKey: args], outputs: [self.outputKey: llmResult.llm_output!])
            return outputs.1
        } else {
            callCatch(error: LangChainError.ChainError, reqId: reqId, cost: cost)
            return Parsed.error
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
//                    print("ctx: \(external_context)")
            inputs.forEach { (key, value) in
                external_context[key] = value
            }
            return external_context
        } else {
            return inputs
        }
    }
}
