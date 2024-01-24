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
            case .success(let data):
                self.resultText = "Was sent.\nIssue #\(data["number"] as? Int ?? 0) created."
            case .failure(let error):
                self.resultText = "Failed to send.\n\(error.message)"
            }
            Core.makeSimpleAlert(title: "Support Ticket", message: self.resultText)
        }
    }
}
