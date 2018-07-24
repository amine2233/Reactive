//
//  Thread.swift
//  Reactive
//
//  Created by Amine Bensalah on 24/07/2018.
//

import Foundation
import Dispatch

public final class Thread {
    
    public static func main<T>(_ a: T, completion: @escaping (T) -> Void) {
        queue(DispatchQueue.main)(a,completion)
    }
    
    public static func queue<T>(_ queue: DispatchQueue) -> (T, @escaping (T) -> Void) -> Void {
        return { a, completion in
            queue.async {
                completion(a)
            }
        }
    }
    
    public static func background<T>(_ a: T, completion: @escaping (T) -> Void) {
        DispatchQueue.global(qos: .background).async {
            completion(a)
        }
    }
}
