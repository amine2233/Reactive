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

    /// The last value of this Observable will not retained, therefore `observable.value` will always be nil.
    /// - Note: Observables without retained values can not be merged.
    public static let NoInitialValue = ObservingOptions(rawValue: 1)
    /// Observables will only fire once for an update and nil out their completion blocks afterwards.
    /// Use this to automatically resolve retain cycles for one-off operations.
    public static let Once = ObservingOptions(rawValue: 2)
}

/**
 A type-erased Observable in order to avoid generic specification when unnecessary.
 */
public protocol Unsubscribable: class {
    func unsubscribe(_ token: ObservableToken)
}

public protocol ObservableProtocol {

    associatedtype Element

    var value: Element? { get }

    func update(_ value: Element)
}

public typealias Observer<T> = (T) -> Void

/**
 An Observable<T> is value that will change over time.

 ```
 let text = Observable("World")

 text.subscribe { string in
 print("Hello \(string)") // prints Hello World
 }

 text.update("Developer") // will invoke the block and print Hello Developer
 ```

 Observables are thread safe.
 */
public final class Observable<T>: ObservableProtocol, Unsubscribable {

    fileprivate var observers = [ObservableToken: Observer<T>]()
    public private(set) var value: T?
    public let options: ObservingOptions
    fileprivate let mutex = Lock()

    /// Create a new observable without a value and the desired options. You can supply a value later via `update`.
    public init(options: ObservingOptions = []) {
        self.options = options
    }

    /**
     Create a new observable from a value, the type will be automatically inferred:

     let magicNumber = Observable(42)

     - Note: See observing options for various upgrades and awesome additions.
     */
    public init(_ value: T, options: ObservingOptions = []) {
        self.options = options
        if !options.contains(.NoInitialValue) {
            self.value = value
        }
    }

    /**
     Create a new observable from an observable completion,
     
     ```
     let magicNumber = Observable<Int> { observable in
        observable.update(42)
     }
     ```
     - Note: See observing options for various upgrades and awesome additions.
     
     - Parameters:
     - options: the desired options.
     - observable: Observable callback.
    */
    public init(options: ObservingOptions = [], observable: @escaping (Observable<T>) -> Void) {
        self.options = options
        observable(self)
    }

    /**
     Create a new observable from an observer completion,
     
     ```
     let magicNumber = Observable<String> { value in
        print(value)
     }
     ```
     - Note: See observing options for various upgrades and awesome additions.
     
     - Parameters:
     - options: the desired options.
     - observer: callback.
    */
    public init(options: ObservingOptions = [], observer: @escaping (T) -> Void) {
        self.options = options
        self.subscribe(observer)
    }

    /**
     Subscribe to the future values of this observable with a block. You can use the obtained
     `ObserverToken` to manually unsubscribe from future updates via `unsubscribe`.

     - Note: This block will be retained by the observable until it is deallocated or the corresponding `unsubscribe`
     function is called.
     */
    @discardableResult
    public func subscribe(_ observer: @escaping (T) -> Void) -> ObservableToken {
        var token: ObservableToken!
        mutex.lock {
            let newHashValue = (observers.keys.map {$0.hashValue}.max() ?? -1) + 1
            token = ObservableToken(observable: self, token: newHashValue)
            if !(options.contains(.Once) && value != nil) {
                observers[token] = observer
            }
            if let value = value, !options.contains(.NoInitialValue) {
                observer(value)
            }
        }
        return token
    }

    /// Update the inner state of an observable and notify all observers about the new value.
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

    /// Update the inner state of an observable and notify all observers about the new value.
    @discardableResult
    public func update(_ observer: Observable<T>) -> ObservableToken {
        return observer.subscribe(update)
    }

    /// Unsubscribe from future updates with the token obtained from `subscribe`. This will also release the observer block.
    public func unsubscribe(_ token: ObservableToken) {
        mutex.lock {
            observers[token] = nil
        }
    }

    /**
     Merge multiple observables of the same type:
     ```
     let greeting: Observable<[String]> = Observable<[String]>.merge([Observable("Hello"), Observable("World")]) // contains ["Hello", "World"]
     ```
     - Precondition: Observables with the option .NoInitialValue do not retain their value and therefore cannot be merged.
     */
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

    /**
     Create a new observable with a transform applied:

     let text = Observable("Hello World")
     let uppercaseText = text.map { $0.uppercased() }
     text.update("yeah!") // uppercaseText will contain "YEAH!"
     */
    public func map<U>(_ transform: @escaping (T) -> U) -> Observable<U> {
        let observable = Observable<U>(options: options)
        subscribe { observable.update(transform($0)) }
        return observable
    }

    /**
     Creates a new observable with a transform applied. The value of the observable will be wrapped in a Result<T> in case the transform throws.
     */
    public func flatMap<U>(_ transform: @escaping (T) -> Observable<U>) -> Observable<U> {
        let observable = Observable<U>(options: options)
        subscribe { transform($0).subscribe(observable.update) }
        return observable
    }

    /**
     Merge observable of the different same type:
     
     - Parameters:
        - merge: Observable will merge value with the current value.
     - Returns: A new `Observable` with tuple.
    */
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

    /**
     Creates a new observable which is updated with values returning true for the
     given filter function.
     */
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
