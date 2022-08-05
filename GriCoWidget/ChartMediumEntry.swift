//
//  EnergyMediumEntry.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.02.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import Foundation
import WidgetKit

struct ChartMediumEntry: TimelineEntry {
    let configuration: ComparisonMediumIntent
    
    public let date: Date
    
    public let firstWidgetMVToday: MeasurementValue
    public let secondWidgetMVToday: MeasurementValue
    
    
    var currentYearlyValues: [Double] = [1300, 1177, 500, 250, 1000, 750, 500, 250, 1000, 750, 500, 250]
    var lastYearlyValues: [Double] = [1100, 950, 625, 100, 600, 750, 500, 250, 400, 750, 500, 250]
    var scaleValues: [Int] = [1000, 750, 500, 250]
    
    public let unit: String
    
    func getYearlyValues(currentYearlyValues: [Double]) -> [Double] {
        currentYearlyValues.map { value in
            value / 10
        }
    }
    
    func getScaleValues() -> [Int] {
        
        let largestCurrentYear = currentYearlyValues.max() ?? 0
        let largestLastYear = lastYearlyValues.max() ?? 0
        let largestValue = max(largestCurrentYear, largestLastYear)
        
        let maxScaleValue = largestValue * 1.1 // +10%
        
        return [Int(maxScaleValue), Int(maxScaleValue*0.75), Int(maxScaleValue*0.5), Int(maxScaleValue*0.25)]
    }
}
