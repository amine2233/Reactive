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
    let futureWithFilterValue = Future<Int, TestError>(value: 2)
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

    let completionModulo = { (value: Int) throws -> Bool in
        if value % 2 == 0 {
            return true
        }
        throw TestError.empty
    }

    let completionModuloFuture = { (value: Int) throws -> Future<Bool, TestError> in
        if value % 2 == 0 {
            return Future(value: true)
        }
        throw TestError.empty
    }

    let completionModuloError = { (error: Error) -> TestError in
        return .empty
    }

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

    func testRecover() {
        let expectation = self.expectation(description: "future recover has correct value")
        var expectedValue = 0

        futureWithValue.recover { _ in return 1 }.execute(onSuccess: { value in
            expectedValue = value
            expectation.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectedValue, 1, "future should have a correct value")
    }

    func testRecoverWithError() {
        let expectation = self.expectation(description: "future recover with failure value")
        var expectedValue = 0

        futureWithError.recover { _ in return 1 }.execute(onSuccess: { value in
            expectedValue = value
            expectation.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectedValue, 1, "future should have a correct value")
    }

    func testFilter() {
        let expectation = self.expectation(description: "future filter has correct value")
        var expectedValue = 0

        futureWithFilterValue.filter { $0 % 2 == 0 }.execute(onSuccess: { value in
            expectedValue = value
            expectation.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectedValue, 2, "future should have a correct value")
    }

    func testFilterWithError() {
        let expectation = self.expectation(description: "future recover with failure value")
        var expectedFailureValue: TestError?

        futureWithError.filter { $0 % 2 == 0 }.execute { result in
            switch result {
            case .failure(let failure):
                expectedFailureValue = failure
                expectation.fulfill()
            case .success:
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(TestError.empty, expectedFailureValue)
    }

    func testFilterError() {
        let expectation = self.expectation(description: "future filter has correct value")
        var expectedFailureValue: Int?

        futureWithValue.filterError { $0 == .empty }.execute { result in
            switch result {
            case .failure:
                expectation.fulfill()
            case .success(let value):
                expectedFailureValue = value
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(1, expectedFailureValue, "future should have a correct value")
    }

    func testFilterErrorWithError() {
        let expectation = self.expectation(description: "future filter has correct value")
        var expectedFailureValue: TestError?

        futureWithError.filterError { $0 == .empty }.execute { result in
            switch result {
            case .failure(let failure):
                expectedFailureValue = failure
                expectation.fulfill()
            case .success:
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(TestError.empty, expectedFailureValue, "future should have a correct value")
    }

    func testMap() {
        let expectation = self.expectation(description: "future recover has correct value")
        var expectedValue = false

        futureWithFilterValue.map(completionModulo, completionModuloError)
            .execute(onSuccess: { value in
            expectedValue = value
            expectation.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(expectedValue, "future should have a correct value")
    }

    func testMapTryCatchSuccess() {
        let expectation = self.expectation(description: "future recover has correct value")
        var expectedValue: TestError?

        futureWithValue.map(completionModulo, completionModuloError)
            .execute { result in
                switch result {
                case .failure(let failure):
                    expectedValue = failure
                    expectation.fulfill()
                case .success:
                    expectation.fulfill()
                }
            }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(TestError.empty, expectedValue, "future should have a correct value")
    }

    func testMapWithError() {
        let expectation = self.expectation(description: "future recover has correct value")
        var expectedValue: TestError?

        futureWithError.map(completionModulo, completionModuloError)
            .execute { result in
                switch result {
                case .failure(let failure):
                    expectedValue = failure
                    expectation.fulfill()
                case .success:
                    expectation.fulfill()
                }
            }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(TestError.empty, expectedValue, "future should have a correct value")
    }

    func testFlatMap() {
        let expectation = self.expectation(description: "future recover has correct value")
        var expectedValue: String?

        futureWithValue.flatMap { return Future<String, TestError>(value: "\($0)") }
            .execute { result in
                switch result {
                case .failure:
                    expectation.fulfill()
                case .success(let value):
                    expectedValue = value
                    expectation.fulfill()
                }
            }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual("1", expectedValue, "future should have a correct value")
    }

    func testFlatMapWithError() {
        let expectation = self.expectation(description: "future recover has correct value")
        var expectedValue: TestError?

        futureWithError.flatMap { return Future<String, TestError>(value: "\($0)") }
            .execute { result in
                switch result {
                case .failure(let failure):
                    expectedValue = failure
                    expectation.fulfill()
                case .success:
                    expectation.fulfill()
                }
            }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(TestError.empty, expectedValue, "future should have a correct value")
    }

    func testFlatMapWithTryTransforError() {
        let expectation = self.expectation(description: "future recover has correct value")
        var expectedValue = false

        futureWithFilterValue.flatMap(completionModuloFuture, completionModuloError)
            .execute(onSuccess: { value in
            expectedValue = value
            expectation.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(expectedValue, "future should have a correct value")
    }

    func testFlatMapWithTryTransforErrorCatchFailure() {
        let expectation = self.expectation(description: "future recover has correct value")
        var expectedValue: TestError?

        futureWithValue.flatMap(completionModuloFuture, completionModuloError)
            .execute { result in
                switch result {
                case .failure(let failure):
                    expectedValue = failure
                    expectation.fulfill()
                case .success:
                    expectation.fulfill()
                }
            }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(TestError.empty, expectedValue, "future should have a correct value")
    }

    func testFlatMapWithTryTransforFailure() {
        let expectation = self.expectation(description: "future recover has correct value")
        var expectedValue: TestError?

        futureWithError.flatMap(completionModuloFuture, completionModuloError)
            .execute { result in
                switch result {
                case .failure(let failure):
                    expectedValue = failure
                    expectation.fulfill()
                case .success:
                    expectation.fulfill()
                }
            }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(TestError.empty, expectedValue, "future should have a correct value")
    }

    func testZip() {
        let expectation = self.expectation(description: "future filter has correct value")
        var expectedValue: (Int, Int)?

        futureWithValue.zip(futureWithFilterValue).execute(onSuccess: { value in
            expectedValue = value
            expectation.fulfill()
        })
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectedValue?.0, 1, "future should have a correct value")
        XCTAssertEqual(expectedValue?.1, 2, "future should have a correct value")
    }
}
