//
//  String.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/17/23.
//

import Foundation

extension String {
    
    var separated: String {
        self
            .replacingOccurrences(of: "([A-Z])", with: " $1", options: .regularExpression, range: range(of: self))
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized
    }
}
