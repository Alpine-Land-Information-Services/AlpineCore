//
//  ErrorLogListView.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 1/19/24.
//

import SwiftUI
import SwiftData

public struct ErrorLogListView: View {
    
    @Environment(CoreAppControl.self) var control
    
    @Query private var errors: [AppError]
    
    public init(userID: String) {
        _errors = Query(filter: #Predicate<AppError> { $0.user?.id == userID }, sort: \.date, order: .reverse)
    }
    
    public var body: some View {
        if errors.isEmpty {
            ContentUnavailableView("No Errors Recorded", systemImage: "hand.thumbsup")
        } else {
            ForEach(errors) { error in
                NavigationLink {
                    ErrorLogView(error: error)
                } label: {
                    HStack {
                        Text(error.title)
                        if let errorTag = error.errorTag, let _ = error.dateSent {
                            Text("(Ref: \(errorTag))")
                            sentLabel
                        }
                        Spacer()
                        Text(error.date.toString(format: "MM-dd-yy HH:mm"))
                            .font(.caption)
                    }
                }
            }
        }
    }
    var sentLabel: some View {
        Text("Sent")
            .font(.caption)
            .padding(4)
            .foregroundColor(.green)
            .background(.ultraThickMaterial)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.green, lineWidth: 1)
            )
    }
}
