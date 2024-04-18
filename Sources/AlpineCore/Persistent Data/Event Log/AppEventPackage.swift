//
//  File.swift
//  AppEventPackage
//
//  Created by Jenya Lebid on 4/18/24.
//

import Foundation
import SwiftData

@Model
public class EventPackage {
    
    var dateCreated = Date()
    var log: String
    
    var user: CoreUser?
    
    init(log: String) {
        self.log = log
    }
    
    func send() {
        guard let user else {
            modelContext?.delete(self)
            return
        }
        
        let sender = SupportTicketSender()
        sender.sendBackgroundReport(title: "App Events", message: log, email: user.id) { [self] success in
            if success {
                modelContext?.delete(self)
            }
        }
    }
}
