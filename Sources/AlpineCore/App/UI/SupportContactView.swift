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
    
    enum IssueLevel: String, CaseIterable {
        case nonUrgent = "Not Urgent"
        case medium = "Unable to Complete Task"
        case broken = "Application not Usable"
    }
    
    @State private var issueLevel: IssueLevel = .nonUrgent
    @State private var supportType: SupportType = .feedback
    @State private var supportComment = ""
    
    @State private var associatedError: AppError?
    
    @ObservedObject var supportTicketSender: SupportTicketSender
    
    var userID: String
    
    public init(userID: String, supportType: SupportType? = nil, associatedError: AppError? = nil) {
        self.userID = userID
        if let supportType {
            self.supportType = supportType
        }    
        if let associatedError {
            self.associatedError = associatedError
        }
        supportTicketSender = SupportTicketSender()
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
        .overlay {
            if supportTicketSender.spinner {
                Rectangle().fill(Color.black).opacity(0.5).ignoresSafeArea()
                ProgressView("Sending...").foregroundColor(Color.white).progressViewStyle(CircularProgressViewStyle(tint: .white))
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
                let reportTitle = "\(supportType.rawValue)"
                var reportText = ""
                supportTicketSender.spinner = true
                switch supportType {
                case .feedback, .featureRequest:
                    reportText = "\(supportComment)"
                case .bug:
                    if let associatedError {
                        reportText = """
                        \(associatedError.title)
                        
                        <--- Bug Severity --->
                        \(issueLevel.rawValue)
                        
                        <--- Associated Error --->
                        [file] \(associatedError.file ?? "")
                        [function] \(associatedError.function ?? "")
                        [line] \(associatedError.line != nil ? String(associatedError.line!) : "")
                        
                        \(associatedError.content)
                        \(associatedError.additionalInfo != nil ? "\n[Additional Info]\n\(associatedError.additionalInfo!)" : "")
                        
                        <--- User Description --->
                        \(supportComment)
                        """
                    }
                    reportText.append("<--- User Description --->\n\(supportComment)")
                }
                supportTicketSender.sendGitReport(title: reportTitle, message: reportText, email: userID)
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
                ErrorListSelectView(userID: userID, selectedError: $associatedError)
            } label: {
                ListLabelBlock(label: "Associated Error") {
                    Text(associatedError?.typeName ?? "Not Selected")
                }
            }
        } footer: {
            Text("Please select an associated error to which this report is corresponds to, if one exists.")
        }
    }
}


