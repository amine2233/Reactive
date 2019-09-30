//
//  ObservableToken.swift
//  Reactive
//
//  Created by Amine Bensalah on 24/07/2018.
//

import Foundation

public final class ObservableToken: Hashable {
    private weak var observable: Unsubscribable?
    public let token: Int

    internal init(observable: Unsubscribable, token: Int) {
        self.token = token
        self.observable = observable
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(token)
    }

    public func unsubscribe() {
        observable?.unsubscribe(self)
    }
}

public func == (lhs: ObservableToken, rhs: ObservableToken) -> Bool {
    return lhs.token == rhs.token
}
