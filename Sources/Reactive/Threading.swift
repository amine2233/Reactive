//
//  Thread.swift
//  Reactive
//
//  Created by Amine Bensalah on 24/07/2018.
//

import Foundation
import Dispatch

/**
 Several functions that should make multithreading simpler.
 Use this functions together with Signal.ensure:
 Signal.ensure(Thread.main) // will create a new Signal on the main queue
 */
public final class Threading {

    /// Transform a signal to the main queue
    public static func main<T>(_ block: T, completion: @escaping (T) -> Void) {
        queue(DispatchQueue.main)(block, completion)
    }

    /// Transform the signal to a specified queue
    public static func queue<T>(_ queue: DispatchQueue) -> (T, @escaping (T) -> Void) -> Void {
        return { block, completion in
            queue.async {
                completion(block)
            }
        }
    }

    /// Transform the signal to a global background queue with priority default
    public static func background<T>(_ block: T, completion: @escaping (T) -> Void) {
        let dispatchQueue = DispatchQueue.global(qos: .background)
        queue(dispatchQueue)(block, completion)
    }
}

public final class Queue {

    /// Transform an observable to the main queue
    public static func main<T>(_ block: T) -> Observable<T> {
        return queue(DispatchQueue.main)(block)
    }

    /// Transform the observalbe to a specified queue
    public static func queue<T>(_ queue: DispatchQueue) -> (T) -> Observable<T> {
        return { value in
            let observable = Observable<T>(options: [.Once])
            queue.async {
                observable.update(value)
            }
            return observable
        }
    }

    /// Transform the observable to a global background queue with priority default
    public static func background<T>(_ block: T) -> Observable<T> {
        let dispatchQueue = DispatchQueue.global(qos: .background)
        return queue(dispatchQueue)(block)
    }
}
