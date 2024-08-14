//
//  ExportType.swift
//  AlpineAtlas
//
//  Created by Vladislav on 8/12/24.
//

import Foundation

/// Represents different types of exportable containers or file paths in the application.
public enum ExportType {
    /// The container for the user's application data, typically located in `ApplicationSupport/User`.
    case userAppContainer
    
    /// The container for the group file system, used for shared data between app extensions.
    case fileSystemContainer
    
    /// The container for user data, typically located in `Docs/Atlas/Shared`.
    case userDataContainer
    
    /// The container for map data within a specific project, typically located in `Docs/Atlas/User/Project/MapData`.
    case mapDataDataContainer
    
    /// A specific file path that should be used for exporting.
    /// - Parameter path: The URL of the file to be exported.
    case file(path: URL)
}
