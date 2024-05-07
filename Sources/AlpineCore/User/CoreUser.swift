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
    
    @Relationship(deleteRule: .cascade, inverse: \AppError.user)
    var errors: [AppError] = []
    
    @Relationship(deleteRule: .cascade, inverse: \AppCrashLog.user)
    var eventLog: [AppCrashLog] = []
    
    @Relationship(deleteRule: .cascade, inverse: \EventPackage.user)
    var eventPackages: [EventPackage] = []
        
    @Relationship(deleteRule: .cascade)
    public var apps: [CoreApp] = []
    
    public var isActive = false
    
    public var app: CoreApp?
            
    public init(id: String) {
        self.id = id
    }
}
