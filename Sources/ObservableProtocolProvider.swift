//
//  ObservableProtocolProvider.swift
//  Reactive
//
//  Created by Amine Bensalah on 24/07/2018.
//

import Foundation

public protocol ObservableProtocolProvider: class {}

public extension ObservableProtocolProvider {
    
    public var reactive: Observable<Self> {
        return Observable(self)
    }
    
    public static var reactive: Observable<Self>.Type {
        return Observable<Self>.self
    }
}

extension NSObject: ObservableProtocolProvider {}

extension ObservableProtocol where Element: NSObject {}
