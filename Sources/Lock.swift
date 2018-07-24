//
//  Lock.swift
//  Reactive
//
//  Created by Amine Bensalah on 24/07/2018.
//

import Foundation
#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

internal class Lock {
    fileprivate var mutex = pthread_mutex_t()

    init() {
        pthread_mutex_init(&mutex, nil)
    }

    deinit {
        pthread_mutex_destroy(&mutex)
    }

    func lock() -> Int32 {
        return pthread_mutex_lock(&mutex)
    }

    @discardableResult
    func unlock() -> Int32 {
        return pthread_mutex_unlock(&mutex)
    }

    func lock(_ closure: () -> Void) {
        let status = lock()
        assert(status == 0, "pthread_mutex_lock: \(strerror(status))")
        defer { unlock() }
        closure()
    }
}
