//
//  ErrorLogView.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 1/19/24.
//

import SwiftUI
import AlpineUI

struct ErrorLogView: View {
    
    var error: AppError
    
    
    var body: some View {
        List {
            Section {
                Text(error.content)
            } header: {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Timestamp: ")
                        Text(error.date.toString(format: "MM-dd-yy HH:mm"))
                    }
                    .font(.callout)
                    .padding(.bottom)
                    Text("Description:")
                        .font(.caption)
                }
                .textCase(.none)
            }
            if let info = error.additionalInfo, !info.isEmpty {
                Section {
                    Text(info)
                } header: {
                    Text("Additional Information:")
                        .font(.caption)
                        .textCase(.none)
                }
            }
        }
        .navigationTitle(error.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let dateSent = error.dateSent {
                    Text("Sent on \(dateSent.toString(format: "MMM d"))")
                        .font(.caption)
                }
                else if error.report != nil {
                    Text("Submited")
                        .font(.caption)
                }
                else {
                    reportButton
                }
            }
        }
    }
    
    @ViewBuilder
    var reportButton: some View {
        if let userID = error.user?.id {
            NavigationLink {
                SupportContactView(userID: userID, supportType: SupportContactView.SupportType.bug, associatedError: error)
            } label: {
                Text("Report")
                    .font(.headline)
                    .foregroundStyle(.green)
            }
            .buttonStyle(.bordered)
        }
    }
}
