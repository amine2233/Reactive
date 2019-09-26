//
//  Timer.swift
//  Reactive
//
//  Created by Amine Bensalah on 24/07/2018.
//

import Foundation

extension Observable {

    /**
     Wait until the observable updates the next time. This will block the current thread until
     there is a new value.
     */
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
            throw ObservableError.timeout
        }
        return value
    }

    /**
     Creates a new observable that mirrors the original observable but is delayed by x seconds.
     If no queue is specified, the new observable will call it's observers and transforms on the main queue.
     */
    public func delay(_ seconds: TimeInterval, queue: DispatchQueue = DispatchQueue.main) -> Observable<T> {
        let observable = Observable<T>()
        subscribe { result in
            queue.asyncAfter(deadline: DispatchTime.now() + seconds) {
                observable.update(result)
            }
        }
        return observable
    }

    /**
     Creates a new bbservable that is only firing once per specified time interval. The last
     call to update will always be delivered (although it might be delayed up to the
     specified amount of seconds).
     */
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
