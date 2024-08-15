//
//  AppLogsView.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/16/24.
//

import SwiftUI
import AlpineUI

public struct AppLogsView: View {
    
    private enum TabSelection: String, CaseIterable {
        case events = "Events"
        case errors = "Errors"
    }
    
    static func hiddenPredicate(userID: String) -> Predicate<AppEventLog> {
        #Predicate<AppEventLog> { $0.userID == userID }
    }
    
    static func visiblePredicate(userID: String) -> Predicate<AppEventLog> {
        #Predicate<AppEventLog> { $0.userID == userID }
    }
    
    @State private var showHidden: Bool = false
    @State private var currentTab = TabSelection.events
    @State private var predicate: Predicate<AppEventLog>
    
    @Environment(CoreAppControl.self) var control

    var userID: String
    
    public init(userID: String) {
        self.userID = userID
        _predicate = State(wrappedValue: Self.visiblePredicate(userID: userID))
    }
    
    public var body: some View {
        List {
            Section {
                switch currentTab {
                case .events:
                    EventLogListView(userID: userID, predicate: predicate)
                case .errors:
                    ErrorLogListView(userID: userID)
                }
            } header: {
                ListPickerBlock(style: .segmented, value: $currentTab) {
                    ForEach(TabSelection.allCases, id: \.self) { selection in
                        Text(selection.rawValue)
                            .tag(selection)
                    }
                }
                .textCase(.none)
                .padding(.bottom)
            }
        }
        .navigationTitle("Application Logs")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if currentTab == .events {
                Menu {
//                    hiddenButton
                    Menu {
                        Text("Choose a timeframe to send logs to the developer.")
                        Button("Last 15 Minutes") {
                            control.createEventPack(interval: -900)
                            Core.logCoreEvent(.submittedEvents, type: .userAction)
                        }
                        Button("Last Hour") {
                            control.createEventPack(interval: -3600)
                            Core.logCoreEvent(.submittedEvents, type: .userAction)
                        }
                        Button("Last Day") {
                            control.createEventPack(interval: -86400)
                            Core.logCoreEvent(.submittedEvents, type: .userAction)
                        }
                    } label: {
                        Label("Send Logs", systemImage: "paperplane")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }

            }
        }
        .onAppear {
            Core.logCoreEvent(.openedApplicationLogs, type: .userAction)
        }
        .modelContainer(CoreAppControl.shared.modelContainer)
    }
    
    var hiddenButton: some View {
        Button {
            showHidden.toggle()
            predicate = showHidden ? Self.hiddenPredicate(userID: userID) : Self.visiblePredicate(userID: userID)
        } label: {
            Label((showHidden ? "Hide Hidden" : "Show Hidden"), systemImage: (showHidden ? "eye.slash" : "eye"))
        }
    }
}
