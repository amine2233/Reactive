//
//  ObservableExtensionTest.swift
//  Reactive
//
//  Created by Amine Bensalah on 27/09/2019.
//

import XCTest
@testable import Reactive

class ObservableExtensionTest: XCTestCase {

    enum TestError: Error {
        case test
    }

    enum NewTestError: Error {
        case newTest
        case newOther
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testObservableExtensionMap() {
        let observable = Observable<Int>()

        let mapExtensionThrow = { (value: Int) throws -> String in
            return "\(value)"
        }

        let expectation = self.expectation(description: "Test observable combine latest")
        var expectationValue: String?

        observable.map(mapExtensionThrow).subscribe { result in
            expectationValue = result.value
            expectation.fulfill()
        }

        observable.update(56)

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectationValue, "56")
    }

    func testObservableExtensionMapThrow() {
        let observable = Observable<Int>()

        let mapExtensionThrow = { (_: Int) throws -> String in
            throw TestError.test
        }

        let expectation = self.expectation(description: "Test observable combine latest")
        var expectationValue: String?

        observable.map(mapExtensionThrow).subscribe { result in
            expectationValue = result.value
            expectation.fulfill()
        }

        observable.update(56)

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNil(expectationValue)
    }

    func testObservableExtensionResultThen() {
        let observable1 = Observable<Result<String, TestError>>()

        let mapExtensionResult = { (value: String) -> Result<String, TestError> in
            return .success("\(value) change")
        }

        let observable3 = observable1.then(mapExtensionResult)

        let expectation = self.expectation(description: "Test observable 1 combine")
        var expectationValue: String?

        observable3.subscribe { value in
            expectationValue = value.value
            expectation.fulfill()
        }

        observable1.update(.success("testValue"))

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectationValue, "testValue change")
    }

    func testObservableExtensionResultThenWithThrowableCallback() {
        let observable1 = Observable<Result<String, TestError>>()

        let mapExtensionResult = { (value: String) throws -> Result<String, TestError> in
            return .success("\(value) change")
        }

        let observable3 = observable1.then(mapExtensionResult)

        let expectation = self.expectation(description: "Test observable 1 combine")
        var expectationValue: String?

        observable3.subscribe { value in
            expectationValue = value.value?.value
            expectation.fulfill()
        }

        observable1.update(.success("testValue"))

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectationValue, "testValue change")
    }

    func testObservableExtensionResultThenMap() {
        let observable1 = Observable<Result<String, TestError>>()

        let mapExtensionResult = { (value: String) -> String in
            return "\(value) change"
        }

        let observable3 = observable1.then(mapExtensionResult)

        let expectation = self.expectation(description: "Test observable 1 combine")
        var expectationValue: String?

        observable3.subscribe { value in
            expectationValue = value.value
            expectation.fulfill()
        }

        observable1.update(.success("testValue"))

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectationValue, "testValue change")
    }

    func testObservableExtensionResultThenError() {
        let observable1 = Observable<Result<String, TestError>>()

        let mapExtensionTransforError = { (value: TestError) -> NewTestError in
            switch value {
            case .test:
                return NewTestError.newTest
            }
        }

        let observable3 = observable1.thenError(mapExtensionTransforError)

        let expectation = self.expectation(description: "Test observable 1 combine")
        var expectationValue: NewTestError?

        observable3.subscribe { value in
            expectationValue = value.error
            expectation.fulfill()
        }

        observable1.update(.failure(.test))

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectationValue, NewTestError.newTest)
    }

    func testObservableExtensionResultThenErrorResult() {
        let observable1 = Observable<Result<String, TestError>>()

        let mapExtensionTransforError = { (value: TestError) -> Result<String, NewTestError> in
            switch value {
            case .test:
                return .failure(.newTest)
            }
        }

        let observable3 = observable1.thenError(mapExtensionTransforError)

        let expectation = self.expectation(description: "Test observable 1 combine")
        var expectationValue: NewTestError?

        observable3.subscribe { value in
            expectationValue = value.error
            expectation.fulfill()
        }

        observable1.update(.failure(.test))

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectationValue, NewTestError.newTest)
    }

    func testObservableExtensionResultThenObservableSuccess() {
        let observable1 = Observable<Result<String, TestError>>()

        let mapExtensionObservableResult = { (value: String) -> Observable<String> in
            return Observable("\(value) change")
        }

        let observable3 = observable1.then(mapExtensionObservableResult)

        let expectation = self.expectation(description: "Test observable 1 combine")
        var expectationValue: String?

        observable3.subscribe { value in
            expectationValue = value.value
            expectation.fulfill()
        }

        observable1.update(.success("testValue"))

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectationValue, "testValue change")
    }

    func testObservableExtensionResultThenObservableFailure() {
        let observable1 = Observable<Result<String, TestError>>()

        let mapExtensionObservableResult = { (value: String) -> Observable<String> in
            return Observable("\(value) change")
        }

        let observable3 = observable1.then(mapExtensionObservableResult)

        let expectation = self.expectation(description: "Test observable 1 combine")
        var expectationValue: TestError?

        observable3.subscribe { value in
            expectationValue = value.error
            expectation.fulfill()
        }

        observable1.update(.failure(TestError.test))

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectationValue, TestError.test)
    }

    func testObservableExtensionResultThenObservableResultSuccess() {
        let observable1 = Observable<Result<String, TestError>>()

        let mapExtensionObservableResult = { (value: String) -> Observable<Result<String, TestError>> in
            return Observable(.success("\(value) change"))
        }

        let observable3 = observable1.then(mapExtensionObservableResult)

        let expectation = self.expectation(description: "Test observable 1 combine")
        var expectationValue: String?

        observable3.subscribe { value in
            expectationValue = value.value
            expectation.fulfill()
        }

        observable1.update(.success("testValue"))

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectationValue, "testValue change")
    }

    func testObservableExtensionResultThenObservableResultFailure() {
        let observable1 = Observable<Result<String, TestError>>()

        let mapExtensionObservableResult = { (value: String) -> Observable<Result<String, TestError>> in
            return Observable(.failure(.test))
        }

        let observable3 = observable1.then(mapExtensionObservableResult)

        let expectation = self.expectation(description: "Test observable 1 combine")
        var expectationValue: TestError?

        observable3.subscribe { value in
            expectationValue = value.error
            expectation.fulfill()
        }

        observable1.update(.success("testValue"))

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectationValue, TestError.test)
    }

    func testObservableExtensionResultPeek() {
        let observable1 = Observable<Result<String, TestError>>()

        let mapExtensionObservableResult = { (value: String) -> Observable<Result<String, TestError>> in
            return Observable(.success("\(value) change"))
        }

        let observable3 = observable1.then(mapExtensionObservableResult)

        let expectation = self.expectation(description: "Test observable 1 combine")

        observable3.subscribe { _ in
            expectation.fulfill()
        }

        observable1.update(.success("testValue"))

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(observable3.peek(), "testValue change")
    }

    func testObservableExtensionResultNext() {
        let observable1 = Observable<Result<String, TestError>>()
        let expectation = self.expectation(description: "Test observable 1 combine")
        var expectationValue: String?
        var expectationValue1: String?
        // var expectationValue2: String?

        _ = observable1.next { (value) in
            expectationValue1 = value
        }
//        .next { (anOther) in
//            expectationValue2 = anOther
//        }
        .subscribe { value in
            expectationValue = value.value
            expectation.fulfill()
        }

        observable1.update(.success("testValue"))

        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(expectationValue, expectationValue1)
        //XCTAssertEqual(expectationValue, expectationValue2)
    }

    func testObservableExtensionResultError() {
        let observable1 = Observable<Result<String, TestError>>()
        let expectation = self.expectation(description: "Test observable 1 combine")
        var expectationValue: TestError?
        var expectationValue1: TestError?

        _ = observable1.error { error in
            expectationValue1 = error
        }

        observable1.subscribe { value in
            if let error = value.error {
                expectationValue = error
            }
            expectation.fulfill()
        }

        observable1.update(.failure(.test))

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectationValue, expectationValue1)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
