//
//  EventLogListView.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/15/24.
//

import SwiftUI
import SwiftData
import OSLog

public struct EventLogListView: View {
        
    @Query private var events: [AppEventLog]
    
    public init(userID: String) {
        _events = Query(filter: #Predicate<AppEventLog> { $0.user?.id == userID }, sort: \.timestamp, order: .reverse)
    }
    
    public var body: some View {
        if events.isEmpty {
            ContentUnavailableView("No events created yet.", systemImage: "pencil.and.list.clipboard")
        }
        else {
            ForEach(events) { event in
                HStack {
                    VStack(alignment: .leading) {
                        Text("At \(event.timestamp.toString(format: "HH:mm, MMM d"))")
                            .font(.caption2)
                        Text(event.event)
                            .font(.callout)
                    }
                    Spacer()
                    Text(event.type.rawValue)
                        .italic()
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

//fileprivate struct SystemLogListView: View {
//    
//    struct SystemLog: Identifiable {
//        
//        public var id = UUID()
//        
//        var date: Date
//        var type: AppEventType
//        var event: String
//                
//        init(_ event: String, date: Date, type: AppEventType) {
//            self.event = event
//            self.date = date
//            self.type = type
//        }
//    }
//            
//    private var entries: [SystemLog] = []
//    
//    public init(userID: String) {
//        let store = try? OSLogStore(scope: .currentProcessIdentifier)
//        let numberOfDays = store?.position(date: Calendar.current.date(byAdding: .day, value: -3, to: .now)!)
//        guard let logs = try? store?.getEntries().compactMap({ $0 as? OSLogEntryLog }).filter({ $0.subsystem == Bundle.main.bundleIdentifier! }) else {
//            return
//        }
//        print(logs)
//        for entry in logs {
//            entries.append(SystemLog(entry.composedMessage, date: entry.date, type: AppEventType(rawValue: entry.category) ?? .system))
//        }
//    }
//    
//    public var body: some View {
//        List {
//            if entries.isEmpty {
//                ContentUnavailableView("No events created yet.", systemImage: "pencil.and.list.clipboard")
//            }
//            else {
//                ForEach(entries) { entry in
//                    HStack {
//                        VStack(alignment: .leading) {
//                            Text("At \(entry.date.toString(format: "HH:mm, MMM d"))")
//                                .font(.caption2)
//                            Text(entry.event)
//                                .font(.callout)
//                        }
//                        Spacer()
//                        Text(entry.type.rawValue)
//                            .italic()
//                            .font(.caption)
//                            .foregroundStyle(.secondary)
//                    }
//                }
//            }
//        }
//        .navigationTitle("Event Log")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}

