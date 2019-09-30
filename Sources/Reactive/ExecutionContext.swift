//
//  ExecutionContext.swift
//  Reactive
//
//  Created by Amine Bensalah on 26/07/2018.
//

import Foundation

public struct ExecutionContext {

    private let context: (@escaping () -> Void) -> Void

    /// Execution context is just a function that executes other function.
    public init(_ context: @escaping (@escaping () -> Void) -> Void) {
        self.context = context
    }

    /// Execute given block in the context.
    public func execute(_ block: @escaping () -> Void) {
        context(block)
    }

    /// Execution context that executes immediately and synchronously on current thread or queue.
    public static var immediate: ExecutionContext {
        return ExecutionContext { block in block() }
    }

    /// Executes immediately and synchronously if current thread is main thread. Otherwise executes
    /// asynchronously on main dispatch queue (main thread).
    public static var immediateOnMain: ExecutionContext {
        return ExecutionContext { block in
            if Thread.isMainThread {
                block()
            } else {
                DispatchQueue.main.async(execute: block)
            }
        }
    }

    /// Execution context that breaks recursive class by ingoring them.
    public static func nonRecursive() -> ExecutionContext {
        var updating: Bool = false
        return ExecutionContext { block in
            guard !updating else { return }
            updating = true
            block()
            updating = false
        }
    }
}
