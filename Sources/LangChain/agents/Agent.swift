//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/19.
//

import Foundation
public class AgentExecutor: DefaultChain {
    let agent: Agent
    let tools: [BaseTool]
    public init(agent: Agent, tools: [BaseTool]) {
        self.agent = agent
        self.tools = tools
    }
    
    public override func call(args: String) async throws -> String {
        // chain run -> call -> agent plan -> llm send
        
        // while should_continue and call
        let name_to_tool_map = tools.map { [$0.name(): $0] }
        
        let intermediate_steps: [(AgentAction, String)] = []
        while true {
            let next_step_output = ActionStep.error
            
            switch next_step_output {
            case .finish:
                print("finish.")
                return ""
            case .action:
                return ""
            default:
                print("default.")
                return ""
            }
        }
    }
}

public func initialize_agent(llm: LLM, tools: [BaseTool]) -> AgentExecutor {
    return AgentExecutor(agent: ZeroShotAgent(), tools: tools)
}

public class Agent {
    let llm_chain: LLMChain? = nil
    
    public init() {
//        prompt = cls.create_prompt(
//                   tools,
//                   prefix=prefix,
//                   suffix=suffix,
//                   format_instructions=format_instructions,
//                   input_variables=input_variables,
//               )
//               llm_chain = LLMChain(
//                   llm=llm,
//                   prompt=prompt,
//                   callback_manager=callback_manager,
//               )
//               tool_names = [tool.name for tool in tools]
//               _output_parser = output_parser or cls._get_default_output_parser()
    }
    
    public func plan() {
        
    }
}

public struct AgentAction{
    let action: String
    let input: String
}
public struct AgentFinish {
    let final: String
}

public enum ActionStep {
    case action(AgentAction)
    case finish(AgentFinish)
    case error
    case pass(String)
}
public class ZeroShotAgent: Agent {
    let output_parser: MRKLOutputParser = MRKLOutputParser()
        
    public func create_prompt(tools: [BaseTool], prefix0: String = PREFIX, suffix: String = SUFFIX, format_instructions: String = FORMAT_INSTRUCTIONS)
        -> PromptTemplate
    {
        let tool_strings = tools.map{$0.name() + ":" + $0.description()}.joined(separator: "\n")
        let tool_names = tools.map{$0.name()}.joined(separator: ", ")
        let format_instructions2 = String(format: format_instructions, tool_names)
        let template = [prefix0, tool_strings, format_instructions2, suffix].joined(separator: "\n\n")
        return PromptTemplate(input_variables: [], template: template)
    }
//        @classmethod
//            def create_prompt(
//                cls,
//                tools: Sequence[BaseTool],
//                prefix: str = PREFIX,
//                suffix: str = SUFFIX,
//                format_instructions: str = FORMAT_INSTRUCTIONS,
//                input_variables: Optional[List[str]] = None,
//            ) -> PromptTemplate:
//                """Create prompt in the style of the zero shot agent.
//
//                Args:
//                    tools: List of tools the agent will have access to, used to format the
//                        prompt.
//                    prefix: String to put before the list of tools.
//                    suffix: String to put after the list of tools.
//                    input_variables: List of input variables the final prompt will expect.
//
//                Returns:
//                    A PromptTemplate with the template assembled from the pieces here.
//                """
//                tool_strings = "\n".join([f"{tool.name}: {tool.description}" for tool in tools])
//                tool_names = ", ".join([tool.name for tool in tools])
//                format_instructions = format_instructions.format(tool_names=tool_names)
//                template = "\n\n".join([prefix, tool_strings, format_instructions, suffix])
//                if input_variables is None:
//                    input_variables = ["input", "agent_scratchpad"]
//                return PromptTemplate(template=template, input_variables=input_variables)
}
