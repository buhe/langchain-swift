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
    let parser: BaseOutputParse
    let stop: [String]
    // todo memory
    
    public init(llm: LLM, prompt: PromptTemplate, parser: BaseOutputParse, stop: [String] = []) {
        self.llm = llm
        self.prompt = prompt
        self.parser = parser
        self.stop = stop
    }
    public override func call(args: String) async throws -> String {
        // ["\\nObservation: ", "\\n\\tObservation: "]
        return await self.llm.send(text: args, stops:  stop)
    }
    
    func generate(input_list: [String]) async -> String {
        // call rest api
        let input_prompt = self.prompt.format(args: input_list)
        do {
            let response = try await call(args: input_prompt)
            return response
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
    
    public func apply(input_list: [String]) async -> ActionStep {
//        let prompts = prep_prompts(input_list: input_list)
        let response: String = await generate(input_list: input_list)
        let results = parser.parse(text: response)
//        for r in response {
//            let step = parser.parse(text: r)
//            results.append(step)
//        }
        return results
    }
    
    public func plan(intermediate_steps: [AgentAction]) {
        
    }
}
