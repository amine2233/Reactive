//
//  CombineExtensions.swift
//  Reactive
//
//  Created by Amine Bensalah on 03/09/2019.
//

import Foundation
#if canImport(Combine)
import Combine

@available(iOS 13.0, *)
extension Observable: Publisher {

    public func receive<S: Subscriber>(subscriber: S) where Observable.Failure == S.Failure, Observable.Output == S.Input {
        subscriber.pushReactiveEvent(self)
    }
}

@available(iOS 13.0, *)
extension Observable: Subject {

    public typealias Output = T
    public typealias Failure = Swift.Error

    public func send(_ value: T) {
        self.update(value)
    }

    public func send(subscription: Subscription) {
        /// no-op: Observable don't complete and can't error out
    }

    public func send(completion: Subscribers.Completion<Error>) {
        /// no-op: Observable don't complete and can't error out
    }
}

@available(iOS 13.0, *)
extension Observable: Subscriber {
    public func receive(completion: Subscribers.Completion<Error>) {
        /// no-op: Observable don't complete and can't error out
    }

    public func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }

    public func receive(_ input: T) -> Subscribers.Demand {
        self.update(input)
        return .unlimited
    }
}

@available(iOS 13.0, *)
extension Subscriber where Failure == Never {
    public func pushReactiveEvent(_ observer: Observable<Input>) {
        observer.subscribe { value in
            _ = self.receive(value)
        }
    }
}

@available(iOS 13.0, *)
extension Subscriber where Failure == Swift.Error {
    public func pushReactiveEvent(_ observer: Observable<Input>) {
        observer.subscribe { value in
            _ = self.receive(value)
        }
    }
}

@available(iOS 13.0, *)
public protocol ObservableConvertible: Subject {
    associatedtype Output

    func asObservable(options: ObservingOptions) -> Observable<Output>
}

@available(iOS 13.0, *)
extension ObservableConvertible {
    public func asObservable(options: ObservingOptions = []) -> Observable<Output> {
        let observable = Observable<Output>(options: options)
        _ = self.sink(receiveCompletion: { _ in
            //
        }, receiveValue: { value in
            observable.update(value)
        })
        return observable
    }
}

@available(iOS 13.0, *)
extension PassthroughSubject: ObservableConvertible {}
@available(iOS 13.0, *)
extension CurrentValueSubject: ObservableConvertible {}

@available(iOS 13.0, *)
extension Observable {

//    public func subscribe<T: ObservableProtocol>(_ observable: T) -> ObservableToken where Element == T.Element {
//        subscribe { value in
//            observable.update(value)
//        }
//    }
//
//    public func bind<S: ObservableConvertible>(to subject: S) -> ObservableToken where S.Output == Element {
//        subscribe(subject.asObservable())
//    }
}

@available(iOS 13.0, *)
extension ObservableToken: Cancellable {
    public func cancel() {
        self.unsubscribe()
    }
}

#endif
