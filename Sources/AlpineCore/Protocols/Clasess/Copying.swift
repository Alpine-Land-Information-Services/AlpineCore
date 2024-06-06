//
//  Copying.swift
//  AlpineCore
//
//  Created by mkv on 6/6/24.
//

import Foundation

public protocol Copying {
    init(original: Self)
}

public extension Copying {
    func copy() -> Self {
        return Self.init(original: self)
    }
}
