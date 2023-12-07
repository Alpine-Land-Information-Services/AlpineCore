//
//  Date.swift
//  AlpineCore
//
//  Created by Jenya Lebid on 5/19/23.
//

import Foundation

public extension Date {
    
    var startOfNextDay: Date {
        let calendar = Calendar.current
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: self) else { return Date() }
        return calendar.startOfDay(for: nextDay)
    }
    
    var hoursSince: Int {
        return Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
    }
}

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
    
    func isNumberOfDays(_ days: Int, since date: Date) -> Bool {
        let calendar = Calendar.current

        let components = calendar.dateComponents([.day], from: date, to: self)
        if let daysDifference = components.day {
            return daysDifference >= days
        }

        return false
    }
    
    func elapsed(_ component: Calendar.Component) -> Int {
        Calendar.current.dateComponents([component], from: self, to: Date()).hour ?? 0
    }
}
