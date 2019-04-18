//
//  Future.swift
//  Promise
//
//  Created by Amine Bensalah on 06/12/2018.
//

import Foundation

/// Future
public struct Future<T, E: Error> {

    // MARK: - Typealias
    public typealias Completion = (Result<T, E>) -> Void
    public typealias AsyncOperation = (@escaping Completion) -> Void
    public typealias FailureCompletion = (E) -> Void
    public typealias SuccessCompletion = (T) -> Void

    // MARK: - Properties
    private let operation: AsyncOperation

    // MARK: - Initialization
    /**
     Initialize a new `Future` with the provided `Result`.
     
     Example usage:
     ````
     let future = Future(result: Result.success(83))
     ````
     
     - Parameters:
        - result: The result of the `Future`. It can be a `Result` of success with a value or failure with an `Error`.
     
     - Returns: A new `Future`.
     */
    public init(result: Result<T, E>) {
        self.init { completion in
            completion(result)
        }
    }

    /**
     Initialize a new `Future` with the provided value.
     
     Example usage:
     ````
     let future = Future(value: 35)
     ````
     
     - Parameters:
        - value: The value of the `Future`.
     
     - Returns: A new `Future`.
     */
    public init(value: T) {
        self.init(result: .success(value))
    }

    /**
     Initialize a new `Future` with the provided `Error`.
     
     Example usage:
     ````
     let f: Future<Int>= Future(error: TypeError.error)
     ````
     - Parameters:
        - error: The error of the `Future`.
     
     - Returns: A new `Future`.
     */
    public init(error: E) {
        self.init(result: .failure(error))
    }

    /**
     Initialize a new `Future` with the provided operation.
     
     Example usage:
     ````
     let future = Future(operation: { completion in
     // Your operation to retrieve the value here
     // Then in case of success you call the completion
     // with the Result passing the value
     completion(.success("Hello"))
     // or in case of error call the completion
     // with the Result passing the error like :
     //completion(.failure(error))
     })
     ````
     
     - Parameters:
        - operation: the operation that should be performed by the Future. This is usually the asynchronous operation.
        - completion: the completion block of the operation. It has the `Result` of the operation as parameter.
     
     - Returns: A new `Future`.
     */
    public init(operation: @escaping (_ completion:@escaping Completion) -> Void) {
        self.operation = operation
    }

    // MARK: - Actions
    /**
     Execute the operation.
     
     Example usage:
     
     ````
     let future = Future(value: 89)
     future.execute(completion: { result in
        switch result {
        case .success(let value):
            print(value) // it will print 89
        case .failure(let error):
            print(error)
        }
     })
     ````
     
     - Parameters:
        - completion: the completion block of the operation. It has the `Result` of the operation as parameter.
     */
    public func execute(completion: @escaping Completion) {
        self.operation { value in
            completion(value)
        }
    }

    /**
     Execute the operation. Example usage
     
         ````
         let future = Future(value: "110")
         future.execute(onSuccess: { value in
            print(value) // it will print 110
         }, onFailure: { error in
            print(error)
         })
         ````
     
     - Parameters:
        - onSuccess: the success completion block of the operation. It has the value of the operation as parameter.
        - onFailure: the failure completion block of the operation. It has the error of the operation as parameter.
     */
    public func execute(onSuccess: @escaping SuccessCompletion, onFailure: FailureCompletion? = nil) {
        self.operation { result in
            switch result {
            case .success(let value):
                onSuccess(value)
            case .failure(let error):
                onFailure?(error)
            }
        }
    }
}

extension Future {

    /**
     Chain two depending futures providing a function that gets the value of this future as parameter
     and then creates new one
     
     ````
     struct User {
        id: Int
     }
     // Let's assume we need to perfom two network operations
     // The first one to get the user id
     // And the second one to get the user information
     // we can use `andThen` to chain them
     let userIdFuture = Future(value: 83)
     func userFuture(by userId: Int) -> Future<User> {
        return Future(value: User(id: userId))
     }
     userIdFuture.andThen(userFuture).execute { user in
        print(user)
     }
     ````
     
     - Parameters:
        - transform: function that will generate a new `Future` by passing the value of this Future
        - value: the value of this Future
     
     - Returns: New chained Future
     */
    public func andThen<U>(_ transform: @escaping (_ value: T) -> Future<U, E>) -> Future<U, E> {
        return Future<U, E>(operation: { completion in
            self.execute(onSuccess: { value in
                transform(value).execute(completion: completion)
            }, onFailure: { error in
                completion(.failure(error))
            })
        })
    }

    /**
     Creates a new Future by applying a function to the successful result of this future.
     If this future is completed with an error then the new future will also contain this error
     
     ````
     let stringFuture = Future(value: "http://intech-consulting.fr")
     let urlFuture = stringFuture.map({URL(string: $0)})
     ````
     - Parameters:
        - transform: function that will generate a new `Future` by passing the value of this Future
        - value: the value of this Future
     
     - Returns: New Future
     */
    public func map<U>(_ transform: @escaping (_ value: T) -> U) -> Future<U, E> {
        return Future<U, E>(operation: { completion in
            self.execute(onSuccess: { value in
                completion(.success(transform(value)))
            }, onFailure: { error in
                completion(.failure(error))
            })
        })
    }
}
