//
//  ObservableCombiningExtension.swift
//  Reactive iOS
//
//  Created by Amine Bensalah on 05/09/2019.
//

import Foundation

extension Observable {

    /**
     combine with an other ```Observable``` with the same type
     
     - Parameters:
     - other: the other ```Observable``` object will combine.
     - Returns: The new ```Observable```
    */
    public func combine(with other: Observable<T>) -> Observable<T> {
        return Observable(observable: { observable in
            let mutex = Lock()
            self.subscribe({ value in
                mutex.lock {
                    observable.update(value)
                }
            })
            other.subscribe({ value in
                mutex.lock {
                    observable.update(value)
                }
            })
        })
    }

    /**
     combine with an other ```Observable``` and transform for a new type
     
     - Parameters:
     - other: the other ```Observable``` object will combine.
     - combine: the callback for transform a result
     - Returns: The new ```Observable```
     */
    public func combineLatest<U,V>(with other: Observable<U>, combine: @escaping (T, U) -> V) -> Observable<V> {
        return Observable<V> { (observable: Observable<V>) in
            let mutex = Lock()
            var elements: (my: T?, other: U?)
            func onNext() {
                if let element = elements.my, let otherElement = elements.other {
                    let combination = combine(element, otherElement)
                    observable.update(combination)
                }
            }
            self.subscribe({ value in
                mutex.lock {
                    elements.my = value
                    onNext()
                }
            })
            other.subscribe({ value in
                mutex.lock {
                    elements.other = value
                    onNext()
                }
            })
        }
    }

    /**
     Zip with an other ```Observable```
     
     - Parameters:
     - other: the other ```Observable``` object will combine.
     - Returns: The new ```Observable```
     */
    public func zip<U>(with other: Observable<U>) -> Observable<(T,U)> {
        return combineLatest(with: other, combine: { ($0,$1) })
    }
}

extension Observable where T: ResultProtocol {
    /**
     combine with an other ```Observable<ResultProtocol>```
     
     - Parameters:
     - other: the other ```Observable``` object will combine.
     - combine: the callback for transform a result
     - Returns: The new ```Observable```
     */
    public func combineLatest<U: ResultProtocol, V: ResultProtocol>(
        with other: Observable<U>,
        combine: @escaping (T.Success, U.Success) -> V
    ) -> Observable<V> where T.Failure == U.Failure, T.Failure == V.Failure {
        return Observable<V>(observable: { observable in
            let mutex = Lock()
            var elements: (my: T.Success?, other: U.Success?)
            func onNext() {
                if let element = elements.my, let otherElement = elements.other {
                    let combination = combine(element, otherElement)
                    observable.update(combination)
                }
            }
            self.subscribe { value in
                mutex.lock {
                    elements.my = value.value
                    onNext()
                }
            }
            other.subscribe { value in
                mutex.lock {
                    elements.other = value.value
                    onNext()
                }
            }
        })
    }
}
