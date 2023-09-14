//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/19.
//

import Foundation
public class AgentExecutor: DefaultChain {
    static let AGENT_REQ_ID = "agent_req_id"
    let agent: Agent
    let tools: [BaseTool]
    public init(agent: Agent, tools: [BaseTool], memory: BaseMemory? = nil, outputKey: String? = nil, callbacks: [BaseCallbackHandler] = []) {
        self.agent = agent
        self.tools = tools
        var cbs: [BaseCallbackHandler] = callbacks
        if Env.addTraceCallbak() && !cbs.contains(where: { item in item is TraceCallbackHandler}) {
            cbs.append(TraceCallbackHandler())
        }
//        assert(cbs.count == 1)
        super.init(memory: memory, outputKey: outputKey, callbacks: cbs)
    }
    
//    def _take_next_step(
//            self,
//            name_to_tool_map: Dict[str, BaseTool],
//            color_mapping: Dict[str, str],
//            inputs: Dict[str, str],
//            intermediate_steps: List[Tuple[AgentAction, str]],
//            run_manager: Optional[CallbackManagerForChainRun] = None,
//        ) -> Union[AgentFinish, List[Tuple[AgentAction, str]]]:
//            """Take a single step in the thought-action-observation loop.
//
//            Override this to take control of how the agent makes and acts on choices.
//            """
//            try:
//                # Call the LLM to see what to do.
//                output = self.agent.plan(
//                    intermediate_steps,
//                    callbacks=run_manager.get_child() if run_manager else None,
//                    **inputs,
//                )
//            except OutputParserException as e:
//                if isinstance(self.handle_parsing_errors, bool):
//                    raise_error = not self.handle_parsing_errors
//                else:
//                    raise_error = False
//                if raise_error:
//                    raise e
//                text = str(e)
//                if isinstance(self.handle_parsing_errors, bool):
//                    if e.send_to_llm:
//                        observation = str(e.observation)
//                        text = str(e.llm_output)
//                    else:
//                        observation = "Invalid or incomplete response"
//                elif isinstance(self.handle_parsing_errors, str):
//                    observation = self.handle_parsing_errors
//                elif callable(self.handle_parsing_errors):
//                    observation = self.handle_parsing_errors(e)
//                else:
//                    raise ValueError("Got unexpected type of `handle_parsing_errors`")
//                output = AgentAction("_Exception", observation, text)
//                if run_manager:
//                    run_manager.on_agent_action(output, color="green")
//                tool_run_kwargs = self.agent.tool_run_logging_kwargs()
//                observation = ExceptionTool().run(
//                    output.tool_input,
//                    verbose=self.verbose,
//                    color=None,
//                    callbacks=run_manager.get_child() if run_manager else None,
//                    **tool_run_kwargs,
//                )
//                return [(output, observation)]
//            # If the tool chosen is the finishing tool, then we end and return.
//            if isinstance(output, AgentFinish):
//                return output
//            actions: List[AgentAction]
//            if isinstance(output, AgentAction):
//                actions = [output]
//            else:
//                actions = output
//            result = []
//            for agent_action in actions:
//                if run_manager:
//                    run_manager.on_agent_action(agent_action, color="green")
//                # Otherwise we lookup the tool
//                if agent_action.tool in name_to_tool_map:
//                    tool = name_to_tool_map[agent_action.tool]
//                    return_direct = tool.return_direct
//                    color = color_mapping[agent_action.tool]
//                    tool_run_kwargs = self.agent.tool_run_logging_kwargs()
//                    if return_direct:
//                        tool_run_kwargs["llm_prefix"] = ""
//                    # We then call the tool on the tool input to get an observation
//                    observation = tool.run(
//                        agent_action.tool_input,
//                        verbose=self.verbose,
//                        color=color,
//                        callbacks=run_manager.get_child() if run_manager else None,
//                        **tool_run_kwargs,
//                    )
//                else:
//                    tool_run_kwargs = self.agent.tool_run_logging_kwargs()
//                    observation = InvalidTool().run(
//                        agent_action.tool,
//                        verbose=self.verbose,
//                        color=None,
//                        callbacks=run_manager.get_child() if run_manager else None,
//                        **tool_run_kwargs,
//                    )
//                result.append((agent_action, observation))
//            return result
    func take_next_step(input: String, intermediate_steps: [(AgentAction, String)]) async -> (Parsed, String) {
        let step = await self.agent.plan(input: input, intermediate_steps: intermediate_steps)
        switch step {
        case .finish(let finish):
            return (step, finish.final)
        case .action(let action):
            let tool = tools.filter{$0.name() == action.action}.first!
            do {
//                print("try call \(tool.name()) tool.")
                var observation = try await tool.run(args: action.input)
                if observation.count > 1000 {
                    observation = String(observation.prefix(1000))
                }
                return (step, observation)
            } catch {
//                print("\(error) at run \(tool.name()) tool.")
                let observation = try! await InvalidTool(tool_name: tool.name()).run(args: action.input)
                return (step, observation)
            }
        default:
            return (step, "default")
        }
    }
    public override func call(args: String) async throws -> LLMResult {
        // chain run -> call -> agent plan -> llm send
        
        // while should_continue and call
//        let name_to_tool_map = tools.map { [$0.name(): $0] }
        let reqId = UUID().uuidString
        for callback in self.callbacks {
            try callback.on_agent_start(prompt: args, metadata: [AgentExecutor.AGENT_REQ_ID: reqId])
        }
        var intermediate_steps: [(AgentAction, String)] = []
        while true {
//            next_step_output = self._take_next_step(
//                name_to_tool_map,
//                color_mapping,
//                inputs,
//                intermediate_steps,
//                run_manager=run_manager,
//            )
            let next_step_output = await self.take_next_step(input: args, intermediate_steps: intermediate_steps)
            
            switch next_step_output.0 {
            case .finish(let finish):
//                print("final answer.")
                for callback in self.callbacks {
                    try callback.on_agent_finish(action: finish, metadata: [AgentExecutor.AGENT_REQ_ID: reqId])
                }
                return LLMResult(llm_output: next_step_output.1)
            case .action(let action):
                for callback in self.callbacks {
                    try callback.on_agent_action(action: action, metadata: [AgentExecutor.AGENT_REQ_ID: reqId])
                }
                intermediate_steps.append((action, next_step_output.1))
            default:
//                print("error step.")
                return LLMResult()
            }
        }
    }
}

public func initialize_agent(llm: LLM, tools: [BaseTool], callbacks: [BaseCallbackHandler] = []) -> AgentExecutor {
    return AgentExecutor(agent: ZeroShotAgent(llm_chain: LLMChain(llm: llm, prompt: ZeroShotAgent.create_prompt(tools: tools), parser: ZeroShotAgent.output_parser, stop: ["\nObservation: ", "\n\tObservation: "])), tools: tools, callbacks: callbacks)
}

public class Agent {
    let llm_chain: LLMChain
    
    public init(llm_chain: LLMChain) {
        self.llm_chain = llm_chain
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
    
    public func plan(input: String, intermediate_steps: [(AgentAction, String)]) async -> Parsed {
//        """Given input, decided what to do.
//
//                Args:
//                    intermediate_steps: Steps the LLM has taken to date,
//                        along with observations
//                    callbacks: Callbacks to run.
//                    **kwargs: User inputs.
//
//                Returns:
//                    Action specifying what tool to use.
//                """
//                output = self.llm_chain.run(
//                    intermediate_steps=intermediate_steps,
//                    stop=self.stop,
//                    callbacks=callbacks,
//                    **kwargs,
//                )
//                return self.output_parser.parse(output)
        return await llm_chain.plan(input: input, agent_scratchpad: construct_agent_scratchpad(intermediate_steps: intermediate_steps))
    }
    
    func construct_agent_scratchpad(intermediate_steps: [(AgentAction, String)]) -> String{
        if intermediate_steps.isEmpty {
            return ""
        }
        var thoughts = ""
        for (action, observation) in intermediate_steps {
            thoughts += action.log
            thoughts += "\nObservation: \(observation)\nThought: "
        }
        return """
            This was your previous work
            but I haven't seen any of it! I only see what "
            you return as final answer):\n\(thoughts)
        """
    }
    
//    def _construct_agent_scratchpad(
//        self, intermediate_steps: List[Tuple[AgentAction, str]]
//    ) -> str:
//        if len(intermediate_steps) == 0:
//            return ""
//        thoughts = ""
//        for action, observation in intermediate_steps:
//            thoughts += action.log
//            thoughts += f"\nObservation: {observation}\nThought: "
//        return (
//            f"This was your previous work "
//            f"(but I haven't seen any of it! I only see what "
//            f"you return as final answer):\n{thoughts}"
//        )
}

public class ZeroShotAgent: Agent {
    static let output_parser: MRKLOutputParser = MRKLOutputParser()
        
    public static func create_prompt(tools: [BaseTool], prefix0: String = PREFIX, suffix: String = SUFFIX, format_instructions: String = FORMAT_INSTRUCTIONS)
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
