//
//  Error.swift
//  AlpineCore
//
//  Created by mkv on 1/19/24.
//

import Foundation

extension Error {
    public func log() -> String {
        "\(self)"
    }
}

//MARK: -
//public struct UnwrapError<T> : Error, CustomStringConvertible {
//    let optional: T?
//    
//    public var description: String {
//        return "Found nil while unwrapping \(String(describing: optional))!"
//    }
//}

public func unwrap<T>(_ optional: T?, message: String? = nil) throws -> T {
    if let real = optional {
        return real
    } else {
        let message = message ?? "Found nil while unwrapping \(String(describing: T.self))"
        throw CoreError(message, type: .nil)
    }
}
