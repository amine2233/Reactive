//
//  FutureTest.swift
//  Promise iOSTests
//
//  Created by Amine Bensalah on 07/12/2018.
//

import XCTest
@testable import Reactive

class FutureTest: XCTestCase {

    enum TestError: Error {
        case empty
    }

    let futureWithValue = Future<Int, TestError>(value: 1)
    let futureWithError = Future<Int, TestError>(error: .empty)
    let futureWithResultValue = Future<Int, TestError>(result: Result.success(1))
    let futureWithResultError = Future<Int, TestError>(result: Result.failure(.empty))
    let futureWithSuccessOperation = Future<Int, TestError> { completion in
        DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
            completion(.success(1))
        })
    }
    let futureWithFailureOperation = Future<Int, TestError> { completion in
        DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
            completion(.failure(.empty))
        })
    }

    let futureWithValueString = Future<String, TestError>(value: "1")

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFutureWithValue() {
        let expectation = self.expectation(description: "future has correct value")
        var expectedValue = 0
        futureWithValue.execute(onSuccess: { value in
            expectedValue = value
            expectation.fulfill()
        })

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectedValue, 1, "future should have a correct value")
    }

    func testFutureWithFailure() {
        let expectation = self.expectation(description: "future should fail")
        var expectedError: TestError?

        futureWithError.execute(onSuccess: { _ in}, onFailure: { error in
            expectedError = error
            expectation.fulfill()
        })

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(expectedError, "future should fail with an error")
        XCTAssertEqual(expectedError, TestError.empty)
    }

    func testFutureWithResultValue() {
        let expectation = self.expectation(description: "future has correct value")
        var expectedValue = 0

        futureWithResultValue.execute(onSuccess: { value in
            expectedValue = value
            expectation.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectedValue, 1, "future should have a correct value")
    }

    func testFutureWithResultError() {
        let expectation = self.expectation(description: "future should fail")
        var expectedError: Error?

        futureWithResultError.execute(onSuccess: {_ in}, onFailure: { error in
            expectedError = error
            expectation.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(expectedError, "future should fail with an error")
    }

    func testFutureWithSuccessOperation() {
        let expectation = self.expectation(description: "future has correct value")
        var expectedValue = 0

        futureWithSuccessOperation.execute(onSuccess: { value in
            expectedValue = value
            expectation.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectedValue, 1, "future should have a correct value")
    }

    func testFutureWithFailureOperation() {
        let expectation = self.expectation(description: "future should fail")
        var expectedError: Error?

        futureWithFailureOperation.execute(onSuccess: {_ in}, onFailure: { error in
            expectedError = error
            expectation.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(expectedError, "future should fail with an error")
    }
}
