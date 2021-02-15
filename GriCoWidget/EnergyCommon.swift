//
//  EnergyCommon.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 22.01.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import Foundation

struct EnergyCommon {
    let date: Date
    
    private static func logC(val: Double, forBase base: Double) -> Double {
        return log(val)/log(base)
    }
    
    public static func getSiPrefix(_ value: Double) -> (String, Double) {
        var result = ("",value)
        
        let pow10 = round(logC(val: abs(value), forBase: 10.0)*100000)/100000
        
        
        if pow10 >= 3.0 {
            result = ("k", value / 1000.0)
        }
        if pow10 >= 6.0 {
            result = ("M", value / 1000_000.0)
        }
        if pow10 >= 9.0 {
            result = ("G", value / 1000_000_000.0)
        }
        if pow10 >= 12.0 {
            result = ("T", value / 1000_000_000_000.0)
        }
        
        return result
    }
    
    public func getDateTimeFormatted() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(for: date) ?? ""
    }
    
    public static func getStartOfWeek(date: Date) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        
        return calendar.date(from: components)!
        
    }
    
    public static func getStartOfMonth(date: Date) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: date)
        
        return calendar.date(from: components)!
        
    }
    
    public static func getStartOfYear(date: Date) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year], from: date)
        
        return calendar.date(from: components)!
        
    }
    
    public static func getDateForLastYear(date: Date, setTo0: Bool) -> Date {
        var dateComponent = DateComponents()
        dateComponent.year = -1
        var lastYearDate = Calendar.current.date(byAdding: dateComponent, to: date)!
        if setTo0 {
            lastYearDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: lastYearDate)!
        }
        return lastYearDate
    }
    
    public static func getUTCDateString(date: Date) -> String {
        return "UTC_\(Int(date.timeIntervalSince1970) * 1000)"
    }
    
    public static func getUTCDateStringForLastYear(date: Date, setTo0: Bool) -> String {
        return getUTCDateString(date: getDateForLastYear(date: date, setTo0: setTo0))
    }
}
