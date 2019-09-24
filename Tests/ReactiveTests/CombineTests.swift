//
//  CombineTests.swift
//  Reactive iOSTests
//
//  Created by Amine Bensalah on 05/09/2019.
//

import XCTest
#if canImport(Combine)
import Combine
#endif
@testable import Reactive

@available(iOS 13.0, *)
class CombineTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testObservableCombine() {
        let expectation = self.expectation(description: "Test observable combine")
        var expectedValue = ""

        let observable = Observable<String>(options: .Once)
        _ = observable.sink(receiveCompletion: { _ in
        }) { value in
            expectedValue = value
            expectation.fulfill()
        }
        
        observable.send("Test")
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectedValue, "Test")
    }
    
    func testCombineCurrentValueSubjectObservable() {
        let expectation = self.expectation(description: "Test combine observable")
        var expectedValue = ""
        
        let publisher = CurrentValueSubject<String, Never>("Publish test")
        _ = publisher.asObservable().subscribe({ value in
            expectedValue = value
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(expectedValue, "Publish test")
    }
    
    func testCombinePassthroughSubjectObservable() {
        let expectation = self.expectation(description: "Test combine observable")
        var expectedValue = ""
        
        let publisher = PassthroughSubject<String, Never>()
        let observer = publisher.asObservable()
        let token = observer.subscribe({ value in
            expectedValue = value
            expectation.fulfill()
        })
        
        publisher.send("Publish test")
        observer.unsubscribe(token)
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectedValue, "Publish test")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
