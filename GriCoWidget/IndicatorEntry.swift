//
//  IndicatorEntry.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.01.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import Foundation
import WidgetKit

struct IndicatorEntry: TimelineEntry {
    let configuration: IndicatorIntent
    
    public let date: Date
    public var mesurementValue: MeasurementValue
    
    mutating func setDigsOnMV(d: Int) -> IndicatorEntry {
        self.mesurementValue.setDigs(d: d)
        return self
    }
    
}
