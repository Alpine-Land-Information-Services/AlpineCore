//
//  File.swift
//  AlpineCore
//
//  Created by mkv on 2/20/24.
//

import Foundation

public extension Int {
    func toStringComaSeparated() -> String {
        Formatter.withSeparator.string(for: Int(self)) ?? ""
    }
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        return formatter
    }()
}
