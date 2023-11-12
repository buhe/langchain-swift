//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/19.
//

import Foundation

public class LLMChain: DefaultChain {
    let llm: LLM
    let prompt: PromptTemplate?
    let parser: BaseOutputParser?
    let stop: [String]
    
    public init(llm: LLM, prompt: PromptTemplate? = nil, parser: BaseOutputParser? = nil, stop: [String] = [], memory: BaseMemory? = nil, outputKey: String = "output", inputKey: String = "input", callbacks: [BaseCallbackHandler] = []) {
        self.llm = llm
        self.prompt = prompt
        self.parser = parser
        self.stop = stop
        super.init(memory: memory, outputKey: outputKey, inputKey: inputKey, callbacks: callbacks)
    }
    func create_outputs(output: LLMResult?) -> Parsed {
        if let output = output {
            if let parser = self.parser {
                return parser.parse(text: output.llm_output!)
            } else {
                return Parsed.str(output.llm_output!)
            }
        } else {
            return Parsed.error
        }
    }
    public override func _call(args: String) async -> (LLMResult?, Parsed) {
        // ["\\nObservation: ", "\\n\\tObservation: "]
        
        let llmResult = await generate(input_list: [inputKey: args])
        
        return (llmResult, create_outputs(output: llmResult))
    }
    func prep_prompts(input_list: [String: String]) -> String {
        if let prompt = self.prompt {
            return prompt.format(args: input_list)
        } else {
            return input_list.first!.value
        }
    }
    func generate(input_list: [String: String]) async -> LLMResult? {
        let input_prompt = prep_prompts(input_list: input_list)
        do {
            //call llm
            let llmResult = await self.llm.generate(text: input_prompt, stops:  stop)
            try await llmResult?.setOutput()
            return llmResult
        } catch {
            print("LLM chain generate \(error.localizedDescription)")
            return nil
        }
    }
    
    public func apply(input_list: [String: String]) async -> Parsed {
        let response = await generate(input_list: input_list)
        return create_outputs(output: response)
    }
    
    public func plan(input: String, agent_scratchpad: String) async -> Parsed {
        return await apply(input_list: ["question": input, "thought": agent_scratchpad])
    }
    
    public func predict(args: [String: String] ) async -> String? {
        let inputAndContext = prep_inputs(inputs: args)
        let outputs = await self.generate(input_list: inputAndContext)
        if let o = outputs {
            let _ = prep_outputs(inputs: args, outputs: [self.outputKey: o.llm_output!])
            return o.llm_output!
        } else {
            return nil
        }
    }
}
