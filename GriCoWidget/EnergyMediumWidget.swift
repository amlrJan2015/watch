//
//  EnergyMediumWidget.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.02.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import WidgetKit
import SwiftUI

struct EnergyMediumWidget: Widget {
    private let kind = "EnergyMediumWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ComparisonMediumIntent.self, provider: EnergyMediumTimeLineProvider()) { entry in
            EnergyMediumEntryView(entry: entry)
        }
        .configurationDisplayName("Energy Medium Widget")
        .description("Energy on Widgets")
        .supportedFamilies([.systemMedium])
    }
}
