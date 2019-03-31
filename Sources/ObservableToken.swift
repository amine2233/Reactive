//
//  ObservableToken.swift
//  Reactive
//
//  Created by Amine Bensalah on 24/07/2018.
//

import Foundation

public final class ObservableToken: Hashable {
    public let hashValue: Int

    internal init(hashValue: Int) {
        self.hashValue = hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(hashValue)
    }
}

public func == (lhs: ObservableToken, rhs: ObservableToken) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
