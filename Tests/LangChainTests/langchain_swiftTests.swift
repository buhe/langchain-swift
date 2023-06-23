import XCTest
@testable import LangChain

final class langchain_swiftTests: XCTestCase {
    func testFormat() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
        let s1 = PromptTemplate(input_variables: ["1", "2"], template: SUFFIX).format(args: [ "dog" , "cat"] )
        XCTAssertNotNil(s1)
    }
    
    func testZeroShotAgent() throws {
        let agent = ZeroShotAgent()
        let tools: [BaseTool] = [Dummy()]
        let p = agent.create_prompt(tools: tools)
//        print(p.format(args: ["cat", "dog"]))
        let c = """
Answer the following questions as best you can. You have access to the following tools:

dummy:Useful for test.

Use the following format:

Question: the input question you must answer
Thought: you should always think about what to do
Action: the action to take, should be one of [dummy]
Action Input: the input to the action
Observation: the result of the action
... (this Thought/Action/Action Input/Observation can repeat N times)
Thought: I now know the final answer
Final Answer: the final answer to the original input question

Begin!

Question: cat
Thought: dog
"""
        XCTAssertEqual(c, p.format(args: ["cat", "dog"]))
    }
}
