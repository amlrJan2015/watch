//
//  Series.swift
//  JanOnVal
//
//  Created by Andreas M on 02.12.23.
//  Copyright © 2023 Andreas Mueller. All rights reserved.
//

import Foundation

struct ChartDataSeries: Identifiable {
    let timePeriod: String
    let pvData: [ChartData]
    var min: Double?
    var max: Double?
    
    var id: String { timePeriod }
    
    mutating func setMin(value: Double) {
        if let minValue = self.min {
            self.min = Swift.min(value, minValue)
        } else {
            self.min = value
        }
    }
    
    mutating func setMax(value: Double) {
        if let maxValue = self.max {
            self.max = Swift.max(value, maxValue)
        } else {
            self.max = value
        }
    }
}
