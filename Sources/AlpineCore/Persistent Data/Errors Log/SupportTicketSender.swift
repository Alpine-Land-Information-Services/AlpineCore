//
//  SupportTicketSender.swift
//  AlpineCore
//
//  Created by mkv on 1/24/24.
//

import Foundation

public class SupportTicketSender: ObservableObject {
    
    @Published var spinner = false
    
    private static var owner: String = ""
    private static var repository: String = ""
    private static var token: String = ""
    
    var resultText = ""
    
    static public func doInit(owner: String, repository: String, token: String) {
        self.owner = owner
        self.repository = repository
        self.token = token
    }
    
    func sendGitReport(title: String, message: String, email: String) {
        defer {
            DispatchQueue.main.async { [weak self] in
                self?.spinner = false
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
                Core.makeSimpleAlert(title: "Something Went Wrong", message: "Please try again later.")
                Core.makeError(error: error, showToUser: false)
            }
        }
    }
    
    func sendBackgroundReport(title: String, message: String, email: String, errorTag: String?, didSend: @escaping (_: Bool) -> Void) {
        guard !Self.owner.isEmpty, !Self.repository.isEmpty, !Self.token.isEmpty else {
            return
        }
        
        if let errorTag {
            uploadFilesForReport(errorTag: errorTag)
        }
        
        GitReport().sendReport(owner: Self.owner,
                               repository: Self.repository,
                               token: Self.token,
                               title: title,
                               message: message,
                               email: email) { result in
            switch result {
            case .success(_):
                didSend(true)
            case .failure(_):
                didSend(false)
            }
        }
    }
    
    private func uploadFilesForReport(errorTag: String?) {
        guard let errorTag else { return }
        Task {
            try await Core.shared.uploader?.uploadFilesInFolderAndCleanup(folder: errorTag)
        }
    }
    
    func markToSendError(_ error: AppError, comments: String, issueLevel: AppError.IssueLevel, repeatable: Bool) -> String {
        let report = error.createReport(issueLevel: issueLevel, comments: comments, repeatable: repeatable)
        let message = error.errorTag != nil ? "Thank you, your report has been submitted.\n(Ref: \(error.errorTag!)" : "Thank you, your report has been submitted."
        Core.makeSimpleAlert(title: "Report Submitted", message: message)
        
        return report
    }
}
