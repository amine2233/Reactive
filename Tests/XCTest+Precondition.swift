import XCTest
@testable import Reactive

extension XCTestCase {
    func expectingPreconditionFailure(expectedMessage: String, block: () -> Void) {
        let expectation = self.expectation(description: "failing precondition")
        // Overwrite `precondition` with something that doesn't terminate but verifies it happened.
        preconditionClosure = {
            (condition, message, file, line) in
            if !condition {
                expectation.fulfill()
                XCTAssertEqual(message, expectedMessage, "precondition message didn't match", file: file, line: line)
            }
        }
        // Call code.
        block()
        // Verify precondition "failed".
        waitForExpectations(timeout: 0.0, handler: nil)
        // Reset precondition.
        preconditionClosure = defaultPreconditionClosure
    }
}
