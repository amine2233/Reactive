//
//  SubjectProtocol.swift
//  Reactive
//
//  Created by Amine Bensalah on 24/07/2018.
//

import Foundation

protocol SubjectProtocol: SignalProtocol, ObservableProtocol {}

public final class Subject<T>: SubjectProtocol {

    fileprivate var observers: [ObservableToken: Observable<T>] = [:]
    public private(set) var value: T?
    public let options: ObservingOptions
    fileprivate let mutex = Lock()

    public init(options: ObservingOptions = []) {
        self.options = options
    }

    public init(_ value: T, options: ObservingOptions = []) {
        self.options = options
        if !options.contains(.NoInitialValue) {
            self.value = value
        }
    }

    @discardableResult
    public func subscribe(_ observer: Observable<T>) -> ObservableToken? {
        var token: ObservableToken?
        mutex.lock {
            let newHashValue = (observers.keys.map({$0.hashValue}).max() ?? -1) + 1
            token = ObservableToken(hashValue: newHashValue)
            if token != nil, !(options.contains(.Once) && value != nil) {
                observers[token!] = observer
            }
            if let value = value, !options.contains(.NoInitialValue) {
                observer.update(value)
            }
        }
        return token
    }

    public func update(_ value: T) {
        mutex.lock {
            if !options.contains(.NoInitialValue) {
                self.value = value
            }
            for observe in observers.values {
                observe.update(value)
            }
            if options.contains(.Once) {
                observers.removeAll()
            }
        }
    }

    public func unsubscribe(_ token: ObservableToken) {
        mutex.lock {
            observers[token] = nil
        }
    }

    public func send(_ newValue: T) {
        value = newValue
        observers.forEach { observable in
            observable.value.update(newValue)
        }
    }
    
    @discardableResult
    public func observe(with observer: Observable<T>) -> ObservableToken? {
        guard let token = self.subscribe(observer) else { return nil }
        return token
    }
    
    public func unsubscribeAll() {
        mutex.lock {
            self.observers.removeAll()
        }
    }
}
