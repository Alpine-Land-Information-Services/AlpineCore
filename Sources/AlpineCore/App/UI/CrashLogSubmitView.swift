//
//  CrashLogSubmitView.swift
//  
//
//  Created by Jenya Lebid on 5/3/24.
//

import SwiftUI

struct CrashLogSubmitView: View {
    
    @State private var crashComments = ""
    
    @Environment(\.dismiss) var dismiss
    
    var lastLuanch: Date?
    var core = CoreAppControl.shared
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    
                } header: {
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .symbolRenderingMode(.multicolor)
                            .frame(height: 100)
                        Text("Application Crash Detected")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(uiColor: .label))
                            .padding(.bottom)
                        Text("\(core.app?.fullAppName ?? "This App") may not have terminitated correctly during last session. \n\nDid you experience a crash?")
                            .multilineTextAlignment(.center)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .textCase(.none)
                    .padding()
                }
                
                Section {
                    TextEditor(text: $crashComments)
                        .frame(height: 160)
                } header: {
                    Text("If so, please describe your last actions to help us resolve the issue as soon as possible.")
                        .textCase(.none)
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button {
                            core.createCrashLog(lastLaunch: lastLuanch, comments: crashComments, didNot: true)
                            dismiss()
                        } label: {
                            Text("I Didn't Notice a Crash")
                                .font(.headline)
                        }
                        .buttonStyle(.bordered)
                        Spacer()
                        Button {
                            core.createCrashLog(lastLaunch: lastLuanch, comments: crashComments, didNot: nil)
                            dismiss()
                        } label: {
                            Text("Submit Report")
                                .font(.headline)
                        }
                        .buttonStyle(.bordered)
                        .tint(.green)
                    }
                    .padding(.vertical)
                    .offset(y: -20)
                }
            }
        }
    }
}
//
//#Preview {
//    VStack {
//        
//    }
//    .sheet(isPresented: .constant(true)) {
//        CrashLogSubmitView()
//    }
//}
