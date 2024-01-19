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
            Text("Make Me!")
        }
        .navigationTitle(error.typeName ?? "Unknown Error")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//#Preview {
//    ErrorLogView()
//}
