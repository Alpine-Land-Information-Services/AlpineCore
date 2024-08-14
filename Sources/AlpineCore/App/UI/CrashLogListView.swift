//
//  CrashLogListView.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 4/16/24.
//

import SwiftUI
import SwiftData


//@available(*, deprecated, message: "CrashLogListView is deprecated. Please don't use it.")
//public struct CrashLogListView: View {
//        
//    @Query private var crashes: [AppCrashLog]
//    
//    public init() {
//        _crashes = Query(sort: \.timestamp, order: .reverse)
//    }
//    
//    public var body: some View {
//        if crashes.isEmpty {
//            ContentUnavailableView("No Crashes Recorded", systemImage: "hand.thumbsup")
//        }
//        else {
//            ForEach(crashes) { crash in
//                HStack {
//                    Text("At \(crash.timestamp.toString(format: "HH:mm, MMM d"))")
//                        .font(.callout)
//                    Spacer()
//                    if crash.isReported {
//                        Text("Reported on \(crash.reportDate?.toString(format: "HH:mm, MMM d") ?? "Unknown")")
//                            .font(.caption)
//                            .foregroundStyle(.secondary)
//                    }
//                    else {
//                        Button {
//                        } label: {
//                            Text("Report")
//                                .font(.headline)
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
