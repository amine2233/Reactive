//
//  ObservableExtension.swift
//  Promise
//
//  Created by Amine Bensalah on 25/07/2018.
//

import Foundation

extension Observable {
    public func map<U, Error>(_ transform: @escaping (T) throws -> U) -> Observable<Result<U, Error>> {
        let observable = Observable<Result<U, Error>>(options: options)
        subscribe { value in
            observable.update(Result(block: { return try transform(value) }))
        }
        return observable
    }
}

extension Observable where T: ResultProtocol {

    /// Observables containing a Result<Value,Error> can be chained to only continue in the success case.
    public func then<NewSuccess>(_ transform: @escaping ((T.Success) -> Result<NewSuccess, T.Failure>)) -> Observable<Result<NewSuccess, T.Failure>> {
        return map { return $0.result.flatMap(transform) }
    }

    /// Observables containing a Result<Value,Error> can be chained to only continue in the success case.
    public func then<NewSuccess>(_ transform: @escaping (T.Success) -> NewSuccess) -> Observable<Result<NewSuccess, T.Failure>> {
        return map { $0.result.map(transform) }
    }

    /// Observables containing a Result<Value,Error> can be chained to only continue in the success case.
    public func then<NewSuccess>(_ transform: @escaping (T.Success) throws -> NewSuccess) -> Observable<Result<NewSuccess, T.Failure>> {
        return map { $0.result.flatMap(transform) }
    }

    /// Observables containing a Result<Value,Error> can be chained to only continue in the failure case.
    public func thenError<NewFailure>(_ transform: @escaping (T.Failure) -> Result<T.Success, NewFailure>)
        -> Observable<Result<T.Success, NewFailure>> where NewFailure : Error {
        return map { $0.result.flatMapError(transform) }
    }

    /// Observables containing a Result<Value,Error> can be chained to only continue in the failure case.
    public func thenError<NewFailure>(_ transform: @escaping (T.Failure) -> NewFailure) -> Observable<Result<T.Success, NewFailure>> where NewFailure : Error {
        return map { $0.result.mapError(transform) }
    }

    /// Observables containing a Result<Value,Error> can be chained to only continue in the failure case.
    public func thenError<NewFailure>(_ transform: @escaping (T.Failure) throws -> NewFailure)
        -> Observable<Result<T.Success, NewFailure>> where NewFailure : Error {
        return map { $0.result.flatMapError(transform) }
    }

    /// Observables containing a Result<Value,Error> can be chained to only continue in the success case.
    public func then<NewSuccess>(_ transform: @escaping (T.Success) -> Observable<NewSuccess>) -> Observable<Result<NewSuccess, T.Failure>> {
        return flatMap { [options] in
            let observer = Observable<Result<NewSuccess, T.Failure>>(options: options)
            switch $0.result {
            case let .success(value): transform(value).subscribe { observer.update(.success($0))}
            case let .failure(error): observer.update(.failure(error))
            }
            return observer
        }
    }

    /// Observables containing a Result<Value,Error> can be chained to only continue in the success case.
    public func then<NewSuccess>(_ transform: @escaping (T.Success) -> Observable<Result<NewSuccess, T.Failure>>) -> Observable<Result<NewSuccess, T.Failure>> {
        return flatMap { [options] in
            switch $0.result {
            case let .success(value): return transform(value)
            case let .failure(error): return Observable<Result<NewSuccess, T.Failure>>(Result.failure(error), options: options)
            }
        }
    }

    /// Only subscribe to successful events.
    @discardableResult
    public func next(_ block: @escaping (T.Success) -> Void) -> Observable<T> {
        subscribe { result in
            if let value = result.value {
                block(value)
            }
        }
        return self
    }

    /// Only subscribe to errors.
    @discardableResult
    public func error(_ block: @escaping (Error) -> Void) -> Observable<T> {
        subscribe { result in
            if let error = result.error {
                block(error)
            }
        }
        return self
    }

    /// Peek at the value of the observable.
    public func peek() -> T.Success? {
        return self.value?.value
    }
}
