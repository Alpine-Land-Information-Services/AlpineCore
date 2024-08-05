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

    func hoursAndMinutes(to date: Date) -> (hours: Int, minutes: Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: self, to: date)
        let hours = components.hour ?? 0
        let totalMinutes = components.minute ?? 0
        return (hours, totalMinutes)
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
    
    func isPast(_ date: Date) -> Bool {
        return self < date
    }
    
    func add(_ component: Calendar.Component, value: Int) -> Date {
        return Calendar.current.date(byAdding: component, value: value, to: self) ?? self
    }
    
    func toPostgresTimestamp() -> String {
        toStringTimeZonePST(dateFormat: "yyyy-MM-dd HH:mm:ss")
    }
    
    func toStringTimeZonePST(dateFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
        return dateFormatter.string(from: self)
    }
    
    func daysBetweenDates(startDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: self)
        let numberOfDays = components.day ?? 0
        return numberOfDays
    }
    
    func dateAndTimetoString(format: String = "yyyy-MM-dd HH:mm") -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func timeIn24HourFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    func convert(from initTimeZone: TimeZone, to targetTimeZone: TimeZone) -> Date {
        let delta = TimeInterval(targetTimeZone.secondsFromGMT(for: self) - initTimeZone.secondsFromGMT(for: self))
        return addingTimeInterval(delta)
    }
    
    func convertToCurrentZone() -> Date {
        guard let gmtTimeZone = TimeZone(abbreviation: "GMT") else {
            print("Invalid GMT time zone")
            return Date()
        }
        return self.convert(from: gmtTimeZone, to: TimeZone.current)
    }

    func convertToGMTZone() -> Date {
        guard let laTimeZone = TimeZone(identifier: "America/Los_Angeles"),
              let gmtTimeZone = TimeZone(abbreviation: "GMT") else {
            print("Invalid time zone")
            return Date()
        }
        return self.convert(from: laTimeZone, to: gmtTimeZone)
    }
    
    func year() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)
        return components.year ?? 0
    }
    
    func startOfMonth() -> Date {
        var components = Calendar.current.dateComponents([.year,.month], from: self)
        components.day = 1
        let firstDateOfMonth: Date = Calendar.current.date(from: components)!
        return firstDateOfMonth
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    func nextDate() -> Date {
        let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: self)
        return nextDate ?? Date()
    }
    
    func previousDate() -> Date {
        let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: self)
        return previousDate ?? Date()
    }
    
    func addMonths(numberOfMonths: Int) -> Date {
        let endDate = Calendar.current.date(byAdding: .month, value: numberOfMonths, to: self)
        return endDate ?? Date()
    }
    
    func removeMonths(numberOfMonths: Int) -> Date {
        let endDate = Calendar.current.date(byAdding: .month, value: -numberOfMonths, to: self)
        return endDate ?? Date()
    }
    
    func removeYears(numberOfYears: Int) -> Date {
        let endDate = Calendar.current.date(byAdding: .year, value: -numberOfYears, to: self)
        return endDate ?? Date()
    }
    
    func getHumanReadableDayString() -> String {
        let weekdays = [
            "Sunday",
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday"
        ]
        
        let calendar = Calendar.current.component(.weekday, from: self)
        return weekdays[calendar - 1]
    }
    
    
    func timeSinceDate(fromDate: Date) -> String {
        let earliest = self < fromDate ? self  : fromDate
        let latest = (earliest == self) ? fromDate : self
        
        let components:DateComponents = Calendar.current.dateComponents([.minute,.hour,.day,.weekOfYear,.month,.year,.second], from: earliest, to: latest)
        let year = components.year  ?? 0
        let month = components.month  ?? 0
        let week = components.weekOfYear  ?? 0
        let day = components.day ?? 0
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        let seconds = components.second ?? 0
        
        
        if year >= 2{
            return "\(year) years ago"
        } else if (year >= 1){
            return "1 year ago"
        } else if (month >= 2) {
            return "\(month) months ago"
        } else if (month >= 1) {
            return "1 month ago"
        } else  if (week >= 2) {
            return "\(week) weeks ago"
        } else if (week >= 1){
            return "1 week ago"
        } else if (day >= 2) {
            return "\(day) days ago"
        } else if (day >= 1){
            return "1 day ago"
        } else if (hours >= 2) {
            return "\(hours) hours ago"
        } else if (hours >= 1){
            return "1 hour ago"
        } else if (minutes >= 2) {
            return "\(minutes) minutes ago"
        } else if (minutes >= 1){
            return "1 minute ago"
        } else if (seconds >= 3) {
            return "\(seconds) seconds ago"
        } else {
            return "Just now"
        }
    }
}
