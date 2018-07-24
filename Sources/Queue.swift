//
//  Queue.swift
//  Reactive
//
//  Created by Amine Bensalah on 24/07/2018.
//

import Foundation
import Dispatch

public final class Queue {
    
    public static func main<T>(_ a: T) -> Observable<T> {
        return queue(DispatchQueue.main)(a)
    }
    
    public static func queue<T>(_ queue: DispatchQueue) -> (T) -> Observable<T> {
        return { t in
            let observable = Observable<T>(options: [.Once])
            queue.async {
                observable.update(t)
            }
            return observable
        }
    }
    
    public static func background<T>(_ a: T) -> Observable<T> {
        let q = DispatchQueue.global(qos: .background)
        return queue(q)(a)
    }
}
