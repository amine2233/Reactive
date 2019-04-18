//
//  Thread.swift
//  Reactive
//
//  Created by Amine Bensalah on 24/07/2018.
//

import Foundation
import Dispatch

public final class Threading {

    public static func main<T>(_ block: T, completion: @escaping (T) -> Void) {
        queue(DispatchQueue.main)(block, completion)
    }

    public static func queue<T>(_ queue: DispatchQueue) -> (T, @escaping (T) -> Void) -> Void {
        return { block, completion in
            queue.async {
                completion(block)
            }
        }
    }

    public static func background<T>(_ block: T, completion: @escaping (T) -> Void) {
        DispatchQueue.global(qos: .background).async {
            completion(block)
        }
    }
}

public final class Queue {

    public static func main<T>(_ block: T) -> Observable<T> {
        return queue(DispatchQueue.main)(block)
    }

    public static func queue<T>(_ queue: DispatchQueue) -> (T) -> Observable<T> {
        return { value in
            let observable = Observable<T>(options: [.Once])
            queue.async {
                observable.update(value)
            }
            return observable
        }
    }

    public static func background<T>(_ block: T) -> Observable<T> {
        let dispatchQueue = DispatchQueue.global(qos: .background)
        return queue(dispatchQueue)(block)
    }
}
