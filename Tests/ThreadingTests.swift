//
//  DebounceTests.swift
//  Reactive
//
//  Created by Amine Bensalah on 08/12/2018.
//

import Foundation
import XCTest
import Dispatch

@testable import Reactive

class ThreadingTests: XCTestCase {

    func testOnMainQueue() {
        let observable = Observable<String>()
        let log: (String) -> Void = { print($0) }
        observable.flatMap(Queue.main).subscribe(log)
    }

    func testOnBackgroundQueue() {
        let observable = Observable<String>()
        let log: (String) -> Void = { print($0) }
        observable.flatMap(Queue.background).subscribe(log)
    }

    func testOnMainThreading() {
    }

    func testOnBackgroundThreading() {
    }
}
