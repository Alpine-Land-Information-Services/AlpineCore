//
//  SupportTicketSender.swift
//  AlpineCore
//
//  Created by mkv on 1/24/24.
//

import Foundation

public class SupportTicketSender: ObservableObject {
    
    var resultText = ""
    @Published var spinner = false
    
    private static var owner: String = ""
    private static var repository: String = ""
    private static var token: String = ""
    
    static public func doInit(owner: String, repository: String, token: String) {
        self.owner = owner
        self.repository = repository
        self.token = token
    }
    
    func sendGitReport(title: String, message: String, email: String) {
        defer {
            DispatchQueue.main.async {
                self.spinner = false
            }
        }
        guard !Self.owner.isEmpty, !Self.repository.isEmpty, !Self.token.isEmpty else {
            resultText = "Repository is not initialized."
            return
        }
        GitReport().sendReport(owner: Self.owner,
                               repository: Self.repository,
                               token: Self.token,
                               title: title,
                               message: message,
                               email: email) { result in
            switch result {
            case .success(_):
                Core.makeSimpleAlert(title: "Thank You", message: "Your inquiry was sent.")
            case .failure(let error):
                Core.makeSimpleAlert(title: "Something Went Wrong", message: error.message)
            }
        }
    }
}
