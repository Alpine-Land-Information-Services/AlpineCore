//
//  CoreAppBackup.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 3/25/24.
//

import Foundation
import SwiftData

@Model
public class CoreAppBackup {
    
    public var dateCreated = Date()
    public var path: String
    public var app: CoreApp?
    public var size: Int
    
    init(path: String, size: Int) {
        self.path = path
        self.size = size
    }
    
    
    public static func create(for app: CoreApp, at url: URL) throws {
        
    }
}
