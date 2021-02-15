//
//  EnergySmallWidget.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.02.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import WidgetKit
import SwiftUI

struct EnergySmallWidget: Widget {
    private let kind = "EnergySmallWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ComparisonSmallIntent.self, provider: EnergySmallTimeLineProvider()) { entry in
            EnergySmallEntryView(entry: entry)
        }
        .configurationDisplayName("Energy Small Widget")
        .description("Energy on Widgets")
        .supportedFamilies([.systemSmall])
    }
}
