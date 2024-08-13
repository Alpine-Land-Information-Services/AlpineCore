//
//  CoreErrorType.swift
//  
//
//  Created by Vladislav on 8/12/24.
//

import Foundation

public enum CoreErrorType: String {
    case fileSystem = "File System Error"
    case json = "JSON Error"
    case `nil` = "Unwrapping Error"
    case upload = "Upload Error"
}
