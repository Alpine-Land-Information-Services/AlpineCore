//
//  AppError.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/17/23.
//

import CoreData

public func makeError(onAction: String, log: String, description: String?, showToUser: Bool = true) {
    AppError.add(onAction: onAction, log: log, description: description)
}

public func makeError(onAction: String, error: Error, description: String?, showToUser: Bool = true) {
    AppError.add(onAction: onAction, log: error.log, description: description)
}

extension AppError {
    
    static func add(onAction: String, log: String, description: String?, in context: NSManagedObjectContext = LogDB.newBackground) {
        context.perform {
            let error = NSManagedObject(entity: NSEntityDescription.entity(forEntityName: AppError.entityName, in: context)!, insertInto: context) as! AppError
            error.guid = UUID()
            error.dateAdded = Date()
            
            error.log = log
            error.logDescription = description
            error.triggerAction = onAction
            
            try? context.save()
        }
    }
}

extension Error {
    
    public var log: String {
        "\(self)"
    }
}
