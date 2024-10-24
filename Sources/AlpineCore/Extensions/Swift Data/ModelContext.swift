//
//  File.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 10/21/24.
//

import Foundation
import SwiftData

public extension ModelContext {
    
    func find<Model: PersistentModel>(by predicate: Predicate<Model>) throws -> Model? {
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        
        return try self.fetch(descriptor).first
    }
    
    func search<Model: PersistentModel>(with predicate: Predicate<Model>) throws -> [Model] {
        let descriptor = FetchDescriptor(predicate: predicate)
        return try self.fetch(descriptor)
    }
    
    
    func getContextEntities<T: PersistentModel>(ofType type: T.Type) throws -> [T] {
        let descriptor = FetchDescriptor<T>()
        return try self.fetch(descriptor)
    }
    
    func getContextEntity<T: PersistentModel>(ofType type: T.Type, with id: PersistentIdentifier) throws -> T {
        let predicate = #Predicate<T> { $0.persistentModelID == id }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        
        guard let entity = try self.fetch(descriptor).first else {
            throw AlpineError( "Could not find entity of type \(T.self) by Persistent ID.",
                file: #file, function: #function, line: #line)
        }
        return entity
    }
    
    func getCoreUser(userID: String) throws -> CoreUser? {
        let descriptor = FetchDescriptor(predicate: #Predicate<CoreUser> { $0.id == userID })
        return try self.fetch(descriptor).first
    }
    
    func getPendingErrors() throws -> [AppError] {
        let descriptor = FetchDescriptor(predicate: #Predicate<AppError> { $0.report != nil })
        return try self.fetch(descriptor)
    }
    
    func getRecentEvents(interval: Double, from date: Date = Date()) throws -> [AppEventLog] {
        let intervalDate = date.addingTimeInterval(interval)
        let descriptor = FetchDescriptor(predicate: #Predicate<AppEventLog> { $0.timestamp >= intervalDate }, sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        return try self.fetch(descriptor)
    }
    
    func getRecentEvents(interval: Double, from date: Date, to endDate: Date) throws -> [AppEventLog] {
        let intervalDate = date.addingTimeInterval(interval)
        let descriptor = FetchDescriptor(predicate: #Predicate<AppEventLog> { $0.timestamp >= intervalDate && $0.timestamp < endDate }, sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        return try self.fetch(descriptor)
    }
    
    func getEvents(before dateInit: Date, limit: Int) throws -> [AppEventLog] {
        var descriptor = FetchDescriptor(predicate: #Predicate<AppEventLog> { $0.timestamp < dateInit }, sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        descriptor.fetchLimit = limit
        return try self.fetch(descriptor)
    }
    
    func getPreCrashEvents(before dateInit: Date) throws -> [AppEventLog] {
        var descriptor = FetchDescriptor(predicate: #Predicate<AppEventLog> { $0.timestamp < dateInit }, sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        descriptor.fetchLimit = 1
        
        if let event = try self.fetch(descriptor).first {
            return try getRecentEvents(interval: -900, from: event.timestamp, to: dateInit)
        }
        return []
    }
    
    func getOldEvents() throws -> [AppEventLog] {
        let threeDaysAgo = Date().addingTimeInterval(-259200)
        let descriptor = FetchDescriptor(predicate: #Predicate<AppEventLog> { $0.timestamp <= threeDaysAgo })
        return try self.fetch(descriptor)
    }
}
