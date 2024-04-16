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
        case crashes = "Crashes"
    }
    
    @State private var currentTab = TabSelection.events
    
    var userID: String
    
    public init(userID: String) {
        self.userID = userID
    }
    
    public var body: some View {
        List {
            Section {
                switch currentTab {
                case .events:
                    EventLogListView(userID: userID)
                case .errors:
                    ErrorLogListView(userID: userID)
                case .crashes:
                    CrashLogListView()
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
    }
}
