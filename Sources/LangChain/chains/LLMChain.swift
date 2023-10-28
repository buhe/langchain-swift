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
    func prep_prompts() {
        // TODO
    }
    func generate(input_list: [String]) async -> LLMResult {
        var input_prompt = ""
        //TODO call prep_prompts
        if let prompt = self.prompt {
            input_prompt = prompt.format(args: input_list)
        }
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

    
//    func prep_prompts(input_list: [[String: String]]) -> [String] {
//        // inputs and prompt build compelete prompt
//        var prompts: [String] = []
//        
//        for i in input_list {
//            var args: [String] = []
//            for name in self.prompt.input_variables {
//                args.append(i[name]!)
//            }
//            prompts.append(self.prompt.format(args: args))
//        }
//        return prompts
//    }
    
    public func apply(input_list: [String]) async -> Parsed {
//        let prompts = prep_prompts(input_list: input_list)
        let response: String = await generate(input_list: input_list).llm_output!
        if let parser = self.parser {
            let results = parser.parse(text: response)
            return results
        } else {
            return Parsed.str(response)
        }
    }
    
    public func plan(input: String, agent_scratchpad: String) async -> Parsed {
        return await apply(input_list: [input, agent_scratchpad])
    }
    
//    public func predict(args: [String: String] ) async -> [String: String] {
//        // predict -> __call__ -> _call
//        let inputAndContext = prep_inputs(inputs: args)
//        let output = await self.generate(input_list: inputAndContext.values.map{$0})
//        // call setOutput to finish output
//        let outputs = prep_outputs(inputs: inputAndContext, outputs: ["Answer": output])
//        return outputs
//    }
    
    
//    public func predict_and_parse(args: [String: String]) async -> Parsed {
//        let output = await self.predict(args: args)["Answer"]!
//        if let parser = self.parser {
//            return parser.parse(text: output)
//        } else {
//            return Parsed.str(output)
//        }
//    }
//    def predict(self, callbacks: Callbacks = None, **kwargs: Any) -> str:
//            """Format prompt with kwargs and pass to LLM.
//
//            Args:
//                callbacks: Callbacks to pass to LLMChain
//                **kwargs: Keys to pass to prompt template.
//
//            Returns:
//                Completion from LLM.
//
//            Example:
//                .. code-block:: python
//
//                    completion = llm.predict(adjective="funny")
//            """
//            return self(kwargs, callbacks=callbacks)[self.output_key]
}
