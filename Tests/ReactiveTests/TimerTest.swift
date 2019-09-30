//
//  TimerTest.swift
//  Reactive iOSTests
//
//  Created by Amine Bensalah on 26/09/2019.
//

import XCTest
@testable import Reactive

class TimerTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWaitObservable() {
        let expectation = self.expectation(description: "test wait observable")
        let observable = Observable<String>()
        observable.update("6")
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(try observable.wait(5), "6")
    }

    func testWaitObservableWithNilTimout() {
        let expectation = self.expectation(description: "test wait observable")
        let observable = Observable<String>()
        observable.update("6")
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(try observable.wait(nil), "6")
    }

    func testWaitObservableThrows() {
        let expectation = self.expectation(description: "test wait observable")
        let observable = Observable<String>()
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertThrowsError(try observable.wait(4), "6")
    }

    func testDelay() {
        let expectation = self.expectation(description: "test delay")
        var expectationValue = ""
        let observable = Observable<String>()
        let newObservable = observable.delay(5.0, queue: .main)
        newObservable.subscribe { test in
            expectationValue = test
            expectation.fulfill()
        }

        observable.update("test")
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(expectationValue, "test")
    }

    func testDebounce() {
        let expectation = self.expectation(description: "test delay")
        var expectationValue = ""
        let observable = Observable<String>()
        let newObservable = observable.debounce(2.0)
        newObservable.subscribe { test in
            if test == "test completion" {
                expectationValue = test
                expectation.fulfill()
            }
        }

        observable.update("test")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            observable.update("test completion")
        }

        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(expectationValue, "test completion")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
