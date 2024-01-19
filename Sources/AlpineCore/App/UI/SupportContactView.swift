//
//  SupportContactView.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 1/19/24.
//

import SwiftUI
import AlpineUI

public struct SupportContactView: View {
    
    enum SupportType: String, CaseIterable {
        case feedback = "Feedback"
        case featureRequest = "Feature Request"
        case bug = "Bug Report"
    }
    
    enum IssueLevel: String, CaseIterable {
        case nonUrgent = "Not Urgent"
        case medium = "Unable to Complete Task"
        case broken = "Application not Usable"
    }
    
    @State private var issueLevel: IssueLevel = .nonUrgent
    @State private var supportType: SupportType = .feedback
    @State private var supportComment = ""
    
    @State private var assosiatedError: AppError?
    
    var userID: String
    
    public init(userID: String) {
        self.userID = userID
    }
    
    public var body: some View {
        List {
            supportPicker
            if supportType == .bug {
                issueType
                error
            }
            comments
            send
        }
        .navigationTitle("Alpine Support")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var supportPicker: some View {
        Section {
            ListPickerBlock(style: .segmented, value: $supportType) {
                ForEach(SupportType.allCases, id: \.self) { type in
                    Text(type.rawValue)
                        .tag(type.rawValue)
                }
            }
        } footer: {
            Text("Select an option which best describes your inquiry.")
        }
    }
    
    var issueType: some View {
        Section {
            ListPickerBlock(title: "Bug Severity", style: .menu, value: $issueLevel) {
                ForEach(IssueLevel.allCases, id: \.self) { level in
                    Text(level.rawValue)
                        .tag(level.rawValue)
                }
            }
        } footer: {
            Text("Select an option which best describes the affect of bug to continue use the application.")
        }
    }
    
    var comments: some View {
        Section {
            TextEditor(text: $supportComment)
                .frame(height: 300)
        } header: {
            Group {
                switch supportType {
                case .feedback:
                    Text("Comments:")
                case .featureRequest:
                    Text("What would you like to see in future versions?")
                case .bug:
                    Text("Describe the Issue:")
                }
            }
            .textCase(.none)
        }
    }
    
    var send: some View {
        Section {
            Button {
                Core.makeSimpleAlert(title: "Support Ticket Sent", message: "Your queue number is 9999 \n\n Estimated Response time: 3 years.")
            } label: {
                Text("Send")
                    .font(.title3)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    var error: some View {
        Section {
            NavigationLink {
                ErrorListSelectView(userID: userID, selectedError: $assosiatedError)
            } label: {
                ListLabelBlock(label: "Assosiated Error") {
                    Text(assosiatedError?.typeName ?? "Not Selected")
                }
            }
        } footer: {
            Text("Please select an assosiated error to which this report is corresponds to, if one exists.")
        }
    }
}


