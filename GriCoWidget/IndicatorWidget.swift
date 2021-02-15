//
//  IndicatorWidget.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.01.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import WidgetKit
import SwiftUI

struct IndicatorWidget: Widget {
    private let kind = "IndicatorWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: IndicatorIntent.self, provider: IndicatorTimeLineProvider()) { entry in
            IndicatorEntryView(entry: entry)
        }
        .configurationDisplayName("Power Widget")
        .description("Power/Indicator on Widgets")
        .supportedFamilies([.systemSmall])
    }
}
