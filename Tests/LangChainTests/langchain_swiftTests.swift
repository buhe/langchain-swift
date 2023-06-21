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
}
