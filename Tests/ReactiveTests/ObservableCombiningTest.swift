//
//  ObservableCombiningTest.swift
//  Reactive
//
//  Created by Amine Bensalah on 27/09/2019.
//

import XCTest
@testable import Reactive

class ObservableCombiningTest: XCTestCase {

    enum TestError: Error {}

    let mapExecution = { (first: Int, second:Float) -> String in
        return "\(first) and \(second)"
    }

    let mapExecutionResult = { (first: Int, second:Float) -> Result<String, TestError> in
        return .success("\(first) and \(second)")
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCombineUpdateFirstObservable() {
        let observable1 = Observable<String>()
        let observable2 = Observable<String>()

        let observable3 = observable1.combine(with: observable2)

        let expectation = self.expectation(description: "Test observable 1 combine")
        var expectationValue = ""

        observable3.subscribe { value in
            expectationValue = value
            expectation.fulfill()
        }

        observable1.update("testValue")

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectationValue, "testValue")
    }

    func testCombineUpdateSecondObservable() {
        let observable1 = Observable<String>()
        let observable2 = Observable<String>()

        let observable3 = observable1.combine(with: observable2)

        let expectation = self.expectation(description: "Test observable 2 combine")
        var expectationValue = ""

        observable3.subscribe { value in
            expectationValue = value
            expectation.fulfill()
        }

        observable2.update("testValue 2")

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectationValue, "testValue 2")
    }

    func testCombineLatestFirstObservable() {
        let observable1 = Observable<Int>()
        let observable2 = Observable<Float>(1.0)

        let observable3: Observable<String> = observable1.combineLatest(with: observable2, combine: mapExecution)

        let expectation = self.expectation(description: "Test observable combine latest")
        var expectationValue = ""

        observable3.subscribe { value in
            expectationValue = value
            expectation.fulfill()
        }

        observable1.update(2)

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectationValue, "2 and 1.0")
    }

    func testCombineLatestSecondObservable() {
        let observable1 = Observable<Int>(1)
        let observable2 = Observable<Float>()

        let observable3: Observable<String> = observable1.combineLatest(with: observable2, combine: mapExecution)

        let expectation = self.expectation(description: "Test observable combine latest")
        var expectationValue = ""

        observable3.subscribe { value in
            expectationValue = value
            expectation.fulfill()
        }

        observable2.update(2.0)

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectationValue, "1 and 2.0")
    }

    func testZipFirstObservable() {
        let observable1 = Observable<Int>()
        let observable2 = Observable<Float>(1.0)

        let observable3: Observable<(Int,Float)> = observable1.zip(with: observable2)

        let expectation = self.expectation(description: "Test observable combine latest")
        var expectationValue: (Int, Float) = (0,0.0)

        observable3.subscribe { value in
            expectationValue = value
            expectation.fulfill()
        }

        observable1.update(2)

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(2, expectationValue.0)
    }

    func testZipSecondObservable() {
        let observable1 = Observable<Int>(2)
        let observable2 = Observable<Float>()

        let observable3: Observable<(Int,Float)> = observable1.zip(with: observable2)

        let expectation = self.expectation(description: "Test observable combine latest")
        var expectationValue: (Int, Float) = (0,0.0)

        observable3.subscribe { value in
            expectationValue = value
            expectation.fulfill()
        }

        observable2.update(2.0)

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(2.0, expectationValue.1)
    }

    func testCombineLatestResultFirstObservable() {
        let observable1 = Observable<Result<Int, TestError>>()
        let observable2 = Observable<Result<Float, TestError>>(.success(1.0))

        let observable3: Observable<Result<String, TestError>> = observable1.combineLatest(with: observable2, combine: mapExecutionResult)

        let expectation = self.expectation(description: "Test observable combine latest")
        var expectationValue: Result<String, TestError> = .success("")

        observable3.subscribe { value in
            if let result = value.value {
                expectationValue = .success(result)
            }
            expectation.fulfill()
        }

        observable1.update(.success(2))

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectationValue.value, "2 and 1.0")
    }

    func testCombineLatestResultSecondObservable() {
        let observable1 = Observable<Result<Int, TestError>>(.success(1))
        let observable2 = Observable<Result<Float, TestError>>()

        let observable3: Observable<Result<String, TestError>> = observable1.combineLatest(with: observable2, combine: mapExecutionResult)

        let expectation = self.expectation(description: "Test observable combine latest")
        var expectationValue: Result<String, TestError> = .success("")

        observable3.subscribe { value in
            if let result = value.value {
                expectationValue = .success(result)
            }
            expectation.fulfill()
        }

        observable2.update(.success(2.0))

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectationValue.value, "1 and 2.0")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
