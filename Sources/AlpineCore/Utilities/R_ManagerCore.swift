//
//  Untitled.swift
//  AlpineCore
//
//  Created by Vladislav on 10/24/24.
//

import Foundation
import SwiftData


//public typealias R = R_ManagerCore
//
//open class R_ManagerCore {
//    
//    public init() {}
//    
//    static func getContextEntities<T>(ofType type: T.Type, in context: ModelContext) throws -> [T] where T: PersistentModel {
//        let descriptor = FetchDescriptor<T>()
//        return try context.fetch(descriptor)
//    }
//    
//    static func getContextEntity<T>(ofType type: T.Type, with id: PersistentIdentifier, in context: ModelContext) throws -> T where T: PersistentModel {
//        let predicate = #Predicate<T> { $0.persistentModelID == id }
//        var descriptor = FetchDescriptor(predicate: predicate)
//        descriptor.fetchLimit = 1
//        
//        guard let entity = try context.fetch(descriptor).first else {
//            throw AlpineError(
//                "Could not find entity of type \(T.self) by Persistent ID.",
//                file: #file,
//                function: #function,
//                line: #line
//            )
//        }
//        return entity
//    }
//    
//    static func getCoreUser(userID: String, in context: ModelContext) throws -> CoreUser? {
//        let descriptor = FetchDescriptor(predicate: #Predicate<CoreUser> { $0.id == userID })
//        return try context.fetch(descriptor).first
//    }
//    
//    
//    static func getPendingErrors(in context: ModelContext) throws -> [AppError] {
//        let descriptor = FetchDescriptor(predicate: #Predicate<AppError> { $0.report != nil })
//        return try context.fetch(descriptor)
//    }
//    
//    static func getRecentEvents(interval: Double, from date: Date = Date(), in context: ModelContext) throws -> [AppEventLog] {
//        let interval = date.addingTimeInterval(interval)
//        
//        let descriptor = FetchDescriptor(predicate: #Predicate<AppEventLog> { $0.timestamp >= interval }, sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
//        return try context.fetch(descriptor)
//    }
//    
//    static func getRecentEvents(interval: Double, from date: Date, to endDate: Date, in context: ModelContext) throws -> [AppEventLog] {
//        let interval = date.addingTimeInterval(interval)
//        
//        let descriptor = FetchDescriptor(predicate: #Predicate<AppEventLog> { $0.timestamp >= interval && $0.timestamp < endDate }, sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
//        
//        return try context.fetch(descriptor)
//    }
//    
//    static func getEvents(before dateInit: Date, limit: Int, in context: ModelContext) throws -> [AppEventLog] {
//        var descriptor = FetchDescriptor(predicate: #Predicate<AppEventLog> { $0.timestamp < dateInit }, sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
//        descriptor.fetchLimit = limit
//        return try context.fetch(descriptor)
//    }
//    
//    static func getPreCrashEvents(before dateInit: Date, in context: ModelContext) throws -> [AppEventLog] {
//        var descriptor = FetchDescriptor(predicate: #Predicate<AppEventLog> { $0.timestamp < dateInit }, sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
//        descriptor.fetchLimit = 1
//        
//        if let event = try context.fetch(descriptor).first {
//            return try getRecentEvents(interval: -900, from: event.timestamp, to: dateInit, in: context)
//        }
//        return []
//    }
//    
//    static func getOldEvents(in context: ModelContext) throws -> [AppEventLog] {
//        let threeDaysAgo = Date().addingTimeInterval(-259200)
//        
//        let descriptor = FetchDescriptor(predicate: #Predicate<AppEventLog> { $0.timestamp <= threeDaysAgo })
//        return try context.fetch(descriptor)
//    }
//}
