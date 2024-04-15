//
//  EventLogListView.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/15/24.
//

import SwiftUI
import SwiftData

public struct EventLogListView: View {
        
    @Query private var events: [AppEventLog]
    
    public init(userID: String) {
        _events = Query(filter: #Predicate<AppEventLog> { $0.user?.id == userID }, sort: \.timestamp, order: .reverse)
    }
    
    public var body: some View {
        List {
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
        .navigationTitle("Event Log")
        .navigationBarTitleDisplayMode(.inline)
    }
}

