//
//  BindableProtocol.swift
//  Reactive
//
//  Created by Amine Bensalah on 26/07/2018.
//

import Foundation
import Dispatch

public protocol BindableProtocol {
    associatedtype Element
    
    func bind(signal: Signal<Element>) -> Void
}

extension SignalProtocol {
    
    public func bind<B: BindableProtocol>(to bindable: B) -> Void where B.Element == Element {
        return bindable.bind(signal: toSignal())
    }
}

extension BindableProtocol where Self: SignalProtocol {
    
    public func bidirectionalBind<B: BindableProtocol & SignalProtocol>(to target: B) -> Void where B.Element == Element {
        let context: ExecutionContext = .nonRecursive()
        observeIn(context).bind(to: target)
        target.observeIn(context).bind(to: self)
    }
}
