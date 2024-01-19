//
//  CoreUser.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 1/18/24.
//

import Foundation
import SwiftData

@Model
public class CoreUser {
    
    @Attribute(.unique)
    public var id: String
    
    @Relationship(deleteRule: .cascade)
    var errors: [AppError] = []
    
//    var bools = [String: AnyHashable]()
    
    public init(id: String) {
        self.id = id
    }
}
