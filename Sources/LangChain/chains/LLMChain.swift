//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/19.
//

import Foundation

public class LLMChain: DefaultChain {
    let llm: LLM
    let prompt: PromptTemplate
    let parser: BaseOutputParser?
    let stop: [String]
    
    public init(llm: LLM, prompt: PromptTemplate, parser: BaseOutputParser? = nil, stop: [String] = [], memory: BaseMemory? = nil, outputKey: String? = nil, callbacks: [BaseCallbackHandler] = []) {
        self.llm = llm
        self.prompt = prompt
        self.parser = parser
        self.stop = stop
        super.init(memory: memory, outputKey: outputKey, callbacks: callbacks)
    }
    public override func call(args: String) async throws -> LLMResult {
        // ["\\nObservation: ", "\\n\\tObservation: "]
        
        let llmResult = await self.llm.send(text: args, stops:  stop)

        return llmResult
    }
    
    func generate(input_list: [String]) async -> String {
        // call rest api
        let input_prompt = self.prompt.format(args: input_list)
        do {
//            print(input_prompt)
            var llmResult = await run(args: input_prompt)
            try await llmResult.setOutput()
            return llmResult.llm_output!
        } catch {
            print(error)
            return ""
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
        let response: String = await generate(input_list: input_list)
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
    
    public func predict(args: [String: String] ) async -> [String: String] {
        // predict -> __call__ -> _call
        let inputAndContext = prep_inputs(inputs: args)
        let output = await self.generate(input_list: inputAndContext.values.map{$0})
        // call setOutput to finish output
        let outputs = prep_outputs(inputs: inputAndContext, outputs: ["Answer": output])
        return outputs
    }
    
    
    public func predict_and_parse(args: [String: String]) async -> Parsed {
        let output = await self.predict(args: args)["Answer"]!
        if let parser = self.parser {
            return parser.parse(text: output)
        } else {
            return Parsed.str(output)
        }
    }
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
