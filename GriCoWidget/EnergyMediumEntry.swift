//
//  EnergyMediumEntry.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.02.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import Foundation
import WidgetKit

struct EnergyMediumEntry: TimelineEntry {
    let configuration: ComparisonMediumIntent
    
    public let date: Date
    
    public let firstWidgetMVToday: MeasurementValue
    public let firstWidgetMVYesterday: MeasurementValue
    
    public let secondWidgetMVToday: MeasurementValue
    public let secondWidgetMVYesterday: MeasurementValue
    
    var extendedComparisonValues: [Double]? = [Double.nan, Double.nan,Double.nan,Double.nan,Double.nan, Double.nan]
    
    public func getScaledValueForExtendedComparison(index: Int) -> (String, String) {
        if index < extendedComparisonValues?.count ?? 0 {
            let firstUnit = configuration.firstWidget?.unit2 ?? ""
            if firstUnit.contains("€") {
                return (String(format:"%.2f", extendedComparisonValues![index]), firstUnit.count > 0 ? firstUnit : "Wh")
            }
            let (siPrefix, newValueToday) = EnergyCommon.getSiPrefix(extendedComparisonValues![index])
            return (String(format:"%.2f", newValueToday), siPrefix+(firstUnit.count > 0 ? firstUnit : "Wh"))
        }
        
        return ("", "Wh")
    }
    
    public func getDegreesForValueTrend(index: Int) -> Double {
        if index+1 < extendedComparisonValues?.count ?? 0 {
            let current = extendedComparisonValues?[index] ?? 0.0
            let last = extendedComparisonValues?[index + 1] ?? 0.0
            
            return getDegree(current: current, last: last)
        }
        
        return 0.0
    }
    
    //TODO share for common
    public func getDegree(current: Double, last: Double) -> Double {
        let delta = current - last
        
        var trendInDegree = abs(delta / (delta > 0.0 ? last : current))
        if delta > 0.0 {
            trendInDegree = 90.0 - trendInDegree * 45.0
        } else if delta == 0.0 {
            trendInDegree = 90.0
        } else {
            trendInDegree = 90.0 + trendInDegree * 45.0
        }
        
        
        
        //        var trendInDegree = last / current * 90.0
        
        if trendInDegree > 180.0 {
            trendInDegree = 180.0
        }
        
        if trendInDegree < 0.0 {
            trendInDegree = 0.0
        }
        
        return trendInDegree
    }
}
