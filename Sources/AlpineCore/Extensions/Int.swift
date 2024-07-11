//
//  File.swift
//  
//
//  Created by Vladislav on 7/10/24.
//

import Foundation

public extension Int {
    func toSizeString() -> String {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        byteCountFormatter.countStyle = .file
        return byteCountFormatter.string(fromByteCount: Int64(self))
    }
    
    func toStringComaSeparated() -> String {
        Formatter.withSeparator.string(for: Int(self)) ?? ""
    }
}

extension Int: CoreParameterValueType {
    public static func value(from parameter: CoreAppParameter) -> Int? {
        return parameter.intValue
    }
}
