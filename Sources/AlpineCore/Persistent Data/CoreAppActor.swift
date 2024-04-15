//
//  CoreAppActor.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/15/24.
//

import Foundation
import SwiftData

actor CoreAppActor: ModelActor {
    
    let modelContainer: ModelContainer
    let modelExecutor: ModelExecutor
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        let context = ModelContext(modelContainer)
        modelExecutor = DefaultSerialModelExecutor(modelContext: context)
    }
    
    func createEvent(_ event: String, type: AppEventType, userID: PersistentIdentifier?) {
        let event = AppEventLog(event, type: type)
        modelContext.insert(event)
        
        if let userID {
            let user = modelContext.model(for: userID) as? CoreUser
            event.user = user
        }

        try? save()
    }
    
    public func createError(error: Error, additionalInfo: String? = nil, userId: PersistentIdentifier) -> PersistentIdentifier {
        let error = AppError.create(error: error, additionalInfo: additionalInfo, in: modelContext)
        let user = modelContext.model(for: userId) as? CoreUser
        user?.errors.append(error)
        
        try? save()
        
        return error.persistentModelID
    }
    
    func save() throws {
        try modelContext.save()
    }
}
