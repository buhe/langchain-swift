//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/19.
//

import Foundation
public class AgentExecutor: DefaultChain {
    let agent: Agent
    
    public init(agent: Agent) {
        self.agent = agent
    }
    
    public override func call(args: String) async throws -> String {
        // chain run -> call -> agent plan -> llm send
        
        // while should_continue and call
        ""
    }
}

public func initialize_agent(llm: LLM) -> AgentExecutor {
    return AgentExecutor(agent: ZeroShotAgent())
}

public class Agent {
    let llm_chain: LLMChain? = nil
    
    public init() {
        
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
