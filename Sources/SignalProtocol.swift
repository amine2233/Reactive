//
//  SignalProtocol.swift
//  Reactive
//
//  Created by Amine Bensalah on 24/07/2018.
//

import Foundation

protocol SignalProtocol {
    
    associatedtype Element
    
    @discardableResult
    func observe(with observer: Observable<Element>) -> ObservableToken?
}

public final class Signal<T>: SignalProtocol {
    
    public typealias Producer = (Observable<T>) -> Void
    private let producer: Producer
    
    public init(producer: @escaping Producer) {
        self.producer = producer
    }
    
    @discardableResult
    public func observe(with observer: Observable<T>) -> ObservableToken? {
        producer(observer)
        return nil
    }
}
