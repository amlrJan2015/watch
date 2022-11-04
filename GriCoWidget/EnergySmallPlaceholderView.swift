//
//  EnergySmallPlaceholderView.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 22.01.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import SwiftUI
import WidgetKit

struct EnergySmallPlaceholderView: View {
    var body: some View {
        EnergySmallEntryView(entry: EnergySmallEntry(configuration: ComparisonSmallIntent(), date: Date(), mesurementValueToday: MeasurementValue(date: Date(), value: 689887987.234, unit: "Wh"), mesurementValueYesterday: MeasurementValue(date: Date(), value: 689887987.234, unit: "Wh")))
    }
}

struct EnergyInlinePlaceholderView: View {
    var body: some View {
        EnergySmallInlineEntryView(entry: EnergySmallEntry(configuration: ComparisonSmallIntent(), date: Date(), mesurementValueToday: MeasurementValue(date: Date(), value: 689887987.234, unit: "Wh"), mesurementValueYesterday: MeasurementValue(date: Date(), value: 689887987.234, unit: "Wh")))
    }
}

struct EnergyRectangularPlaceholderView: View {
    var body: some View {
        EnergySmallRectangularEntryView(entry: EnergySmallEntry(configuration: ComparisonSmallIntent(), date: Date(), mesurementValueToday: MeasurementValue(date: Date(), value: 689887987.234, unit: "Wh"), mesurementValueYesterday: MeasurementValue(date: Date(), value: 689887987.234, unit: "Wh")))
    }
}

struct EnergyCircularPlaceholderView: View {
    var body: some View {
        EnergySmallCircularEntryView(entry: EnergySmallEntry(configuration: ComparisonSmallIntent(), date: Date(), mesurementValueToday: MeasurementValue(date: Date(), value: 689887987.234, unit: "Wh"), mesurementValueYesterday: MeasurementValue(date: Date(), value: 689887987.234, unit: "Wh")))
    }
}


struct EnergySmallPlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        EnergySmallPlaceholderView()
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("SystemSmall")
        EnergyInlinePlaceholderView()
            .previewContext(WidgetPreviewContext(family: .accessoryInline))
            .previewDisplayName("Inline")
        EnergyRectangularPlaceholderView()
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            .previewDisplayName("Rectangular")
        EnergyCircularPlaceholderView()
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
            .previewDisplayName("Circular")
    }
}
