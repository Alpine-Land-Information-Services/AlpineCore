//
//  ErrorLogView.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 1/19/24.
//

import SwiftUI
import AlpineUI

struct ErrorLogView: View {
    
    @State private var refreshFlag = false
    
    var error: AppError
    
    var body: some View {
        List {
            Section {
                Text(error.content)
            } header: {
                VStack(alignment: .leading) {
                    Group {
                        HStack {
                            Text("Timestamp: ")
                            Text(error.date.toString(format: "MM-dd-yy HH:mm"))
                        }
                        if let errorTag = error.errorTag, let dateSent = error.dateSent {
                            HStack {
                                Text("Reference number: ")
                                Text(errorTag)
                            }
                        }
                    }
                    .font(.callout)

                    Text("Description:")
                        .padding(.top)
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
                } else if error.report != nil {
                    Text("Submited")
                        .font(.caption)
                } else {
                    reportButton
                }
            }
        }
        .onAppear {
            refreshFlag.toggle()
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
