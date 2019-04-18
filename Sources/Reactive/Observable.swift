//
//  Observable.swift
//  Reactive
//
//  Created by Amine Bensalah on 24/07/2018.
//

import Foundation

public struct ObservingOptions: OptionSet {

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let NoInitialValue = ObservingOptions(rawValue: 1)

    public static let Once = ObservingOptions(rawValue: 2)
}

public protocol ObservableProtocol {

    associatedtype Element

    var value: Element? { get }
}

public typealias Observer<T> = (T) -> Void

public final class Observable<T>: ObservableProtocol {

    fileprivate var observers = [ObservableToken: Observer<T>]()
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
    public func subscribe(_ observer: @escaping (T) -> Void) -> ObservableToken {
        var token: ObservableToken!
        mutex.lock {
            let newHashValue = (observers.keys.map {$0.hashValue}.max() ?? -1) + 1
            token = ObservableToken(token: newHashValue)
            if !(options.contains(.Once) && value != nil) {
                observers[token] = observer
            }
            if let value = value, !options.contains(.NoInitialValue) {
                observer(value)
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
                observe(value)
                if options.contains(.Once) {
                    observers.removeAll()
                }
            }
        }
    }

    public func unsubscribe(_ token: ObservableToken) {
        mutex.lock {
            observers[token] = nil
        }
    }

    public static func merge<U>(_ observables: [Observable<U>], options: ObservingOptions = []) -> Observable<[U]> {
        let merged = Observable<[U]>(options: options)
        let copies = observables.map { $0.map { return $0 } }
        for observable in copies {
            precondition(!observable.options.contains(.NoInitialValue), "Event style observables do not support merging")
            observable.subscribe { value in
                let values = copies.compactMap { $0.value }
                if values.count == copies.count {
                    merged.update(values)
                }
            }
        }
        return merged
    }
}

extension Observable {

    public func map<U>(_ transform: @escaping (T) -> U) -> Observable<U> {
        let observable = Observable<U>(options: options)
        subscribe { observable.update(transform($0)) }
        return observable
    }

    public func flatMap<U>(_ transform: @escaping (T) -> Observable<U>) -> Observable<U> {
        let observable = Observable<U>(options: options)
        subscribe { transform($0).subscribe(observable.update) }
        return observable
    }

    public func merge<U>(_ merge: Observable<U>) -> Observable<(T, U)> {
        let signal = Observable<(T, U)>()
        self.subscribe { aleft in
            if let bright = merge.value {
                signal.update((aleft, bright))
            }
        }
        merge.subscribe { bright in
            if let aleft = self.value {
                signal.update((aleft, bright))
            }
        }
        return signal
    }

    public func filter(_ whereFilter: @escaping (T) -> Bool) -> Observable<T> {
        let observable = Observable<T>()
        subscribe { value in
            if whereFilter(value) {
                observable.update(value)
            }
        }
        return observable
    }
}
