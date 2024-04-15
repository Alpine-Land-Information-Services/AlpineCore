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
        List {
            if errors.isEmpty {
                ContentUnavailableView("No Errors Recorded", systemImage: "hand.thumbsup")
            }
            else {
                ForEach(errors) { error in
                    NavigationLink {
                        ErrorLogView(error: error)
                    } label: {
                        HStack {
                            Text(error.title)
                            Spacer()
                            Text(error.date.toString(format: "MM-dd-yy HH:mm"))
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .navigationTitle("Error Log")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ErrorListSelectView: View {
    
    @Environment(CoreAppControl.self) var control
    @Environment(\.dismiss) var dismiss
    @Query private var errors: [AppError]
    
    @Binding var selectedError: AppError?
    
    @State private var editMode = EditMode.inactive
    
    @State var multiSelection = Set<AppError>()
    
    public init(userID: String, selectedError: Binding<AppError?>) {
        _errors = Query(filter: #Predicate<AppError> { $0.user?.id == userID }, sort: \.date, order: .reverse)
        _selectedError = selectedError
    }
    
    public var body: some View {
        List(selection: $selectedError) {
            Section {
                ForEach(errors, id: \.self) { error in
                    HStack {
                        Text(error.title)
                        Spacer()
                        Text(error.date.toString(format: "MM-dd-yy HH:mm"))
                            .font(.caption)
                    }
                }
            } header: {
                Text("Select a corresponding error to your support request, if one exists.")
                    .textCase(.none)
            }

        }
        .environment(\.editMode, .constant(.active))
        .navigationTitle("Error Selection")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    selectedError = nil
                    dismiss()
                } label: {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.headline)
                }
            }
        }
    }
}

