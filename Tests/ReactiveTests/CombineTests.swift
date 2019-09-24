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

    enum TestError: Swift.Error {
        case test
    }

    var token: ObservableToken?
    var observer: Observable<String>?
    var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        if let token = token {
            observer?.unsubscribe(token)
        }
        subscriptions.forEach { $0.cancel() }
    }

    func testObservableCombine() {
        let expectation = self.expectation(description: "Test observable combine")
        var expectedValue = ""

        let observable = Observable<String>(options: .Once)
        observable.sink(receiveCompletion: { _ in
                            // niet
                        },
                        receiveValue: { value in
                            expectedValue = value
                            expectation.fulfill()
                        })
                        .store(in: &subscriptions)

        observable.send("Test")

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectedValue, "Test")
    }

    func testCombineCurrentValueSubjectObservable() {
        let expectation = self.expectation(description: "Test combine observable")
        var expectedValue = ""

        let publisher = CurrentValueSubject<String, Never>("Publish test")
        publisher
            .asObservable()
            .subscribe({ value in
                expectedValue = value
                expectation.fulfill()
            })
            .store(in: &subscriptions)

        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(expectedValue, "Publish test")
    }

    func testCombinePassthroughSubjectObservable() {
        let expectation = self.expectation(description: "Test combine observable")
        var expectedValue = ""

        let publisher = PassthroughSubject<String, Never>()
        self.observer = publisher
            .asObservable()

        self.token = self.observer!.subscribe({ value in
            expectedValue = value
            expectation.fulfill()
        })

        publisher.send("Publish test")

        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertEqual(expectedValue, "Publish test")
    }
}
