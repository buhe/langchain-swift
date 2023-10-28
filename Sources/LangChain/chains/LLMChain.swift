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
    
    public init(llm: LLM, prompt: PromptTemplate? = nil, parser: BaseOutputParser? = nil, stop: [String] = [], memory: BaseMemory? = nil, outputKey: String? = nil, callbacks: [BaseCallbackHandler] = []) {
        self.llm = llm
        self.prompt = prompt
        self.parser = parser
        self.stop = stop
        super.init(memory: memory, outputKey: outputKey, callbacks: callbacks)
    }
    func create_outputs(output: LLMResult) -> Parsed {
        if let parser = self.parser {
            return parser.parse(text: output.llm_output!)
        } else {
            return Parsed.str(output.llm_output!)
        }
    }
    public override func _call(args: String) async throws -> (LLMResult, Parsed) {
        // ["\\nObservation: ", "\\n\\tObservation: "]
        
        let llmResult = await generate(input_list: [args])
        
        return (llmResult, create_outputs(output: llmResult))
    }
    func prep_prompts(input_list: [String]) -> String {
        if let prompt = self.prompt {
            return prompt.format(args: input_list)
        } else {
            return input_list[0]
        }
    }
    func generate(input_list: [String]) async -> LLMResult {
        let input_prompt = prep_prompts(input_list: input_list)
        do {
            //call llm
            var llmResult = await self.llm.generate(text: input_prompt, stops:  stop)
            try await llmResult.setOutput()
            return llmResult
        } catch {
            print(error)
            return LLMResult()
        }
    }
    
    public func apply(input_list: [String]) async -> Parsed {
        let response = await generate(input_list: input_list)
        return create_outputs(output: response)
    }
    
    public func plan(input: String, agent_scratchpad: String) async -> Parsed {
        return await apply(input_list: [input, agent_scratchpad])
    }
}
