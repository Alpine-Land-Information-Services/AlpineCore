//
//  SupportContactView.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 1/19/24.
//

import SwiftUI

import AlpineUI

public struct SupportContactView: View {
    
    public enum SupportType: String, CaseIterable {
        case feedback = "Feedback"
        case featureRequest = "Feature Request"
        case bug = "Bug Report"
    }
    
    @State private var issueLevel: AppError.IssueLevel = .nonUrgent
    @State private var repeatable = false
    
    @State private var supportType: SupportType = .feedback
    @State private var supportComment = ""
    
    @State private var associatedError: AppError?
    @StateObject private var supportTicketSender = SupportTicketSender()
    
    @Environment(\.dismiss) var dismiss
    
    var network = NetworkTracker.shared
    
    var userID: String
    
    var isManual: Bool
    
    public init(userID: String, supportType: SupportType? = nil, associatedError: AppError? = nil) {
        self.userID = userID
        if let supportType {
            _supportType = State(initialValue: supportType)
        }
        if let associatedError {
            _associatedError = State(initialValue: associatedError)
        }
        
        isManual = associatedError == nil
    }
    
    public var body: some View {
        List {
            if isManual {
                supportPicker
            }
            if supportType == .bug {
                issueType
                isRepeatable
                if isManual {
                    error
                }
            }
            comments
        }
        .onAppear {
            Core.logCoreEvent(.openedSupport, typ: .userAction)
        }
        .navigationTitle(isManual ? "Alpine Support" : "Report Error")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if supportTicketSender.spinner {
                ZStack {
                    Rectangle().fill(Color.black).opacity(0.5).ignoresSafeArea()
                    ProgressView("Sending...").foregroundColor(Color.white).progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    var supportPicker: some View {
        Section {
            ListPickerBlock(style: .segmented, value: $supportType) {
                ForEach(SupportType.allCases, id: \.self) { type in
                    Text(type.rawValue)
                        .tag(type.rawValue)
                }
            }
            .disabled(!isManual)
        } footer: {
            Text("Select an option which best describes your inquiry.")
        }
    }
    
    var issueType: some View {
        Section {
            ListPickerBlock(title: "Issue Severity", style: .menu, value: $issueLevel) {
                ForEach(AppError.IssueLevel.allCases, id: \.self) { level in
                    Text(level.rawValue)
                        .tag(level.rawValue)
                }
            }
        } footer: {
            Text("Select an option which best describes the affect of bug to continue use the application.")
        }
    }
    
    var isRepeatable: some View {
        Section {
            ListToggleBlock(title: "Able To Replicate", isOn: $repeatable, eventTracker: Core.eventTracker)
        } footer: {
            Text("Are you able to replicate the issue? If so, please describe the steps below.")
        }
    }
    
    var comments: some View {
        Section {
            TextEditor(text: $supportComment)
                .frame(height: 240)
        } header: {
            Group {
                switch supportType {
                case .feedback:
                    Text("Comments:")
                case .featureRequest:
                    Text("What would you like to see in future versions?")
                case .bug:
                    Text("Please describe the process by which you encountered the issue with as much detail as possible:")
                }
            }
            .textCase(.none)
        } footer: {
            send
        }
    }
    
    var send: some View {
        Button {
            let reportTitle = "\(supportType.rawValue)"
            var reportText = ""
            switch supportType {
            case .feedback, .featureRequest:
                reportText = "\(supportComment)"
            case .bug:
                if associatedError == nil {
                    reportText = """
                    \(reportTitle)
                    
                    <--- Bug Severity --->
                    \(issueLevel.rawValue)
                    
                    ASSOCIATED ERROR NOT PROVIDED
                    
                    <--- User Description --->
                    \(supportComment.isEmpty ? "Not Provided" : supportComment)
                    """
                }
            }
            if let associatedError {
                let report = supportTicketSender.markToSendError(associatedError, comments: supportComment, issueLevel: issueLevel, repeatable: repeatable)
                if network.isConnected {
                    supportTicketSender.sendBackgroundReport(title: reportTitle, message: report, email: userID) { sent in
                        if sent {
                            associatedError.markSent()
                        }
                        DispatchQueue.main.async {
                            dismiss()
                        }
                    }
                }
                else {
                    dismiss()
                }
            }
            else {
                network.connectedAction {
                    supportTicketSender.spinner = true
                    supportTicketSender.sendGitReport(title: reportTitle, message: reportText, email: userID)
                    dismiss()
                }
            }
        } label: {
            Text(associatedError == nil ? "Send" : "Submit")
                .font(.title3)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .padding()
    }
    
    var error: some View {
        Section {
            NavigationLink {
                ErrorListSelectView(userID: userID, selectedError: $associatedError)
            } label: {
                ListLabelBlock(label: "Associated Error") {
                    Text(associatedError?.title ?? "Not Selected")
                }
            }
        } footer: {
            Text("Select an error to which this report is corresponds to, if one exists.")
        }
    }
}
