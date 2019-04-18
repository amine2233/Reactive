//
//  ObservableToken.swift
//  Reactive
//
//  Created by Amine Bensalah on 24/07/2018.
//

import Foundation

public final class ObservableToken: Hashable {
    public let token: Int

    internal init(token: Int) {
        self.token = token
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(token)
    }
}

public func == (lhs: ObservableToken, rhs: ObservableToken) -> Bool {
    return lhs.token == rhs.token
}
