//
//  EnergySmallEntry.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.02.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import Foundation
import WidgetKit

struct EnergySmallEntry: TimelineEntry {
    let configuration: ComparisonSmallIntent
    
    public let date: Date
    public var mesurementValueToday: MeasurementValue
    public var mesurementValueYesterday: MeasurementValue
    
    mutating func setDigsOnMVToday(d: Int) -> EnergySmallEntry {
        self.mesurementValueToday.setDigs(d: d)
        self.mesurementValueYesterday.setDigs(d: d)
        return self
    }
}
