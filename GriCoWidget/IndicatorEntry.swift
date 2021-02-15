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
    public let mesurementValue: MeasurementValue
    
}
