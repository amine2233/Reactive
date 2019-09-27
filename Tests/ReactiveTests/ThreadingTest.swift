//
//  ThreadingTest.swift
//  Reactive
//
//  Created by Amine Bensalah on 26/09/2019.
//

import XCTest
@testable import Reactive

class ThreadingTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMainThreading() {
        let expectation = self.expectation(description: "Test main threading")

        var expectationValue = ""

        Threading.main("value change") { value in
            expectationValue = value
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectationValue, "value change")
    }

    func testMainThreadingIfIsInMainThreading() {
        let expectation = self.expectation(description: "Test main threading")

        var isMainThreading = false

        Threading.main("") { _ in
            isMainThreading = Thread.isMainThread
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(isMainThreading)
    }

    func testBackgroundThreading() {
        let expectation = self.expectation(description: "Test background threading")

        var expectationValue = ""

        Threading.background("value change in background") { value in
            expectationValue = value
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectationValue, "value change in background")
    }

    func testBackgroundThreadingIfIsInBackgroundThreading() {
        let expectation = self.expectation(description: "Test main threading")

        var isMainThreading = false

        Threading.background("") { _ in
            isMainThreading = Thread.isMainThread
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertFalse(isMainThreading)
    }

    func testMainQueue() {
        let expectation = self.expectation(description: "Test main threading")

        var expectationValue = ""

        _ = Queue.main("value change").subscribe { value in
            expectationValue = value
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectationValue, "value change")
    }

    func testMainQueueIfIsInMainQueue() {
        let expectation = self.expectation(description: "Test main threading")

        var isMainThreading = false

        _ = Queue.main("").subscribe { _ in
            isMainThreading = Thread.isMainThread
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(isMainThreading)
    }

    func testBackgroundQueue() {
        let expectation = self.expectation(description: "Test background threading")

        var expectationValue = ""

        _ = Queue.background("value change in background").subscribe { value in
            expectationValue = value
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectationValue, "value change in background")
    }

    func testBackgroundQueueIfIsInBackgroundQueue() {
        let expectation = self.expectation(description: "Test main threading")

        var isMainThreading = false

        _ = Queue.background("").subscribe { _ in
            isMainThreading = Thread.isMainThread
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertFalse(isMainThreading)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
