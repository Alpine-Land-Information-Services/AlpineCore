//
//  Date.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 5/19/23.
//

import Foundation

public extension Date {
    
    func toString(format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func passedTime(from date: Date, to endDate: Date = Date()) -> String {
        let difference = Calendar.current.dateComponents([.minute, .second], from: date, to: endDate)
        
        let strMin = String(format: "%02d", difference.minute ?? 00)
        let strSec = String(format: "%02d", difference.second ?? 00)
        
        return "\(strMin):\(strSec)"
    }
}
