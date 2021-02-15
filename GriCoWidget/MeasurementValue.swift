//
//  MeasurementValue.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 16.10.20.
//  Copyright © 2020 Andreas Mueller. All rights reserved.
//

import Foundation

struct MeasurementValue: Decodable {
    let date: Date
    let value: Double
    let unit: String
    
    
    public func getScaledValue() -> (String, String) {
        let (siPrefix, newValue) = EnergyCommon.getSiPrefix(value)
        return (String(format:"%.2f", newValue), siPrefix+unit)
    }
    
    public func getDateTimeFormatted() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(for: date) ?? ""
    }
    
    public func getDegree(last: Double) -> Double {
        let delta = value - last
        
        var trendInDegree = abs(delta / (delta > 0.0 ? last : value))
        if delta > 0.0 {
            trendInDegree = 90.0 - trendInDegree * 45.0
        } else if delta == 0.0 {
            trendInDegree = 90.0
        } else {
            trendInDegree = 90.0 + trendInDegree * 45.0
        }
        
        if trendInDegree > 180.0 {
            trendInDegree = 180.0
        }
        
        if trendInDegree < 0.0 {
            trendInDegree = 0.0
        }
        
        return trendInDegree
    }
}
