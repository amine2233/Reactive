//
//  ResultExtension.swift
//  Reactive
//
//  Created by Amine Bensalah on 07/04/2019.
//

import Foundation

public protocol ResultProtocol {

    associatedtype Success

    associatedtype Failure: Error

    /// Returns the associated value if the result is a success, `nil` otherwise.
    var value: Success? { get }

    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    var error: Failure? { get }

    /// Get Result value
    var result: Result<Success, Failure> { get }
}

extension Result: ResultProtocol where Failure: Error {

    public var value: Success? {
        switch self {
        case let .success(value):
            return value
        default:
            return nil
        }
    }

    public var error: Failure? {
        switch self {
        case let .failure(error):
            return error
        default:
            return nil
        }
    }

    /// Get Result value
    public var result: Result<Success, Failure> {
        return self
    }

    public init(block: () throws -> Success) {
        do {
            self = try .success(block())
        } catch let error {
            self = .failure(error as! Failure)
        }
    }

    /// Returns the result of applying `transform` to `Success`es’ values, or re-wrapping `Failure`’s errors.
    public func flatMap<NewSuccess>(_ transform: (Success) -> Result<NewSuccess, Failure>) -> Result<NewSuccess, Failure> {
        switch self {
        case let .success(value): return transform(value)
        case let .failure(error): return .failure(error)
        }
    }

    /// Returns a new Result by mapping `Success`es’ values using `transform`, or re-wrapping `Failure`s’ errors.
    public func map<NewSuccess>(_ transform: (Success) -> NewSuccess) -> Result<NewSuccess, Failure> {
        return flatMap { .success(transform($0)) }
    }

    public func flatMap<NewSuccess>(_ transform: (Success) throws -> NewSuccess) -> Result<NewSuccess, Failure> {
        return flatMap { value in
            do {
                return .success(try transform(value))
            } catch let error {
                return .failure(error as! Failure)
            }
        }
    }

    public func flatMapError<NewFailure>(_ transform: (Failure) -> Result<Success, NewFailure>) -> Result<Success, NewFailure> where NewFailure : Error {
        switch self {
        case let .success(value): return .success(value)
        case let .failure(failure): return transform(failure)
        }
    }

    public func mapError<NewFailure>(_ transform: (Failure) -> NewFailure) -> Result<Success, NewFailure> where NewFailure: Error {
        return flatMapError { .failure(transform($0)) }
    }

    public func flatMapError<NewFailure>(_ transform: (Failure) throws -> NewFailure) -> Result<Success, NewFailure> where NewFailure: Error {
        switch self {
        case let .success(value): return .success(value)
        case let .failure(failure): do { return .failure(try transform(failure)) } catch let error { return .failure(error as! NewFailure) }
        }
    }
}
