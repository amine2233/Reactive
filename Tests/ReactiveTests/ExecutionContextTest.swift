//
//  ExecutionContextTest.swift
//  Reactive
//
//  Created by Amine Bensalah on 26/09/2019.
//

import XCTest
@testable import Reactive

class ExecutionContextTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExecutionContextCreation() {
        let expectation = self.expectation(description: "test wait observable")
        var expectationValue = ""

        let process = {
            expectationValue = "execute block"
            expectation.fulfill()
        }

        let block = {
            // empty execution block
        }

        let context = ExecutionContext { completion in
            process()
            completion()
        }
        context.execute(block)

        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual("execute block", expectationValue)
    }

    func testExecutionContextEmidate() {
        let expectation = self.expectation(description: "test wait observable")
        var expectationValue = ""

        let process = {
            expectationValue = "execute block"
            expectation.fulfill()
        }

        let imediate = ExecutionContext.immediate
        imediate.execute(process)

        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual("execute block", expectationValue)
    }

    func testExecutionContextEmidateOnMainInMainThread() {
        let expectation = self.expectation(description: "test wait observable")
        var expectationValue = ""

        let process = {
            expectationValue = "execute block"
            expectation.fulfill()
        }

        let imediate = ExecutionContext.immediateOnMain
        imediate.execute(process)

        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual("execute block", expectationValue)
    }

    func testExecutionContextEmidateOnMainInGlobalThread() {
        let expectation = self.expectation(description: "test wait observable")
        var expectationValue = ""

        DispatchQueue.global().async {
            let process = {
                expectationValue = "execute block"
                expectation.fulfill()
            }

            let imediate = ExecutionContext.immediateOnMain
            imediate.execute(process)
        }

        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual("execute block", expectationValue)
    }

    func testExecutionContextNonRecursive() {
        let expectation = self.expectation(description: "test wait observable")
        var expectationValue = ""

        let process = {
            expectationValue = "execute block"
            expectation.fulfill()
        }

        let imediate = ExecutionContext.nonRecursive()
        imediate.execute(process)

        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual("execute block", expectationValue)
    }

    func testExecutionContextNonRecursiveNotUpdated() {
        let expectation = self.expectation(description: "test wait observable")
        var expectationValue = ""

        let process = {
            expectationValue = "execute block"
            expectation.fulfill()
        }

        let anOtherProcess = {
        }

        let imediate = ExecutionContext.nonRecursive()
        imediate.execute(process)
        imediate.execute(anOtherProcess)

        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual("execute block", expectationValue)
    }
}
