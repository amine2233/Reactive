//
//  Timer.swift
//  Reactive
//
//  Created by Amine Bensalah on 24/07/2018.
//

import Foundation

public extension Observable {

    public func wait(_ timeout: TimeInterval? = nil) throws -> T {
        let group = DispatchGroup()
        var value: T! = nil
        group.enter()
        subscribe {
            value = $0
            group.leave()
        }
        let timestamp = timeout.map { DispatchTime.now() + $0 } ?? DispatchTime.distantFuture
        if group.wait(timeout: timestamp) != .success {
            throw NSError(domain: "Timeout error", code: 0, userInfo: nil)
        }
        return value
    }

    public func delay(_ seconds: TimeInterval, queue: DispatchQueue = DispatchQueue.main) -> Observable<T> {
        let observable = Observable<T>()
        subscribe { result in
            queue.asyncAfter(deadline: DispatchTime.now() + seconds) {
                observable.update(result)
            }
        }
        return observable
    }

    public func debounce(_ seconds: TimeInterval) -> Observable<T> {
        let observable = Observable<T>()
        var lastCalled: Date?
        subscribe { value in
            let currentTime = Date()
            func updateIfNeeded(_ observable: Observable<T>) -> (T) -> Void {
                return { value in
                    let timeSinceLastCall = lastCalled?.timeIntervalSinceNow
                    if timeSinceLastCall == nil || timeSinceLastCall! <= -seconds {
                        lastCalled = Date()
                        observable.update(value)
                    } else {
                        if currentTime.compare(lastCalled!) == .orderedDescending {
                            let obs = Observable<T>()
                            obs.delay(seconds - timeSinceLastCall!).subscribe(updateIfNeeded(observable))
                            obs.update(value)
                        }
                    }
                }
            }
            updateIfNeeded(observable)(value)
        }
        return observable
    }
}
