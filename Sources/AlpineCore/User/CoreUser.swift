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
    
//    @Relationship(deleteRule: .cascade, inverse: \ApplicationError.user)
//    @Relationship(deleteRule: .cascade)
//    var errors: [ApplicationError] = []
    
//    var bools = [String: AnyHashable]()
    
    init(id: String) {
        self.id = id
    }
}
