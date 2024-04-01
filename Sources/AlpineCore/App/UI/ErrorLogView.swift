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
            VStack {
                TextAreaBlock(title: "Description", text: .constant(error.content), height: 240, changed: .constant(false))
                    .disabled(true)
                if let info = error.additionalInfo {
                    TextAreaBlock(title: "Additional Information", text: .constant(info), height: 200, changed: .constant(false))
                }
            }
        }
        .navigationTitle(error.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let userID = error.user?.id {
                    NavigationLink(destination: SupportContactView(userID: userID, 
                                                                   supportType: SupportContactView.SupportType.bug,
                                                                   associatedError: error)) {
                        Label("Report", systemImage: "ladybug")
                            .labelStyle(.titleAndIcon)
                            .foregroundColor(.orange)
                    }
                }
//                Text(error.date.toString(format: "MMM d, h:mm a"))
//                    .font(.footnote)
            }
        }
    }
}
