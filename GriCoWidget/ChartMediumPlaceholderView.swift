//
//  EnergyMediumPlaceholderView.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.02.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import SwiftUI
import WidgetKit

struct ChartMediumPlaceholderView: View {
    var body: some View {
        ChartMediumEntryView(entry: ChartMediumEntry(configuration: ComparisonMediumIntent(), date: Date(),
                                                       firstWidgetMVToday: MeasurementValue(date: Date(), value: 689887987.234, unit: "Wh"),
                                                       secondWidgetMVToday: MeasurementValue(date: Date(), value: 689887987.234, unit: "W"), unit: "kWh"))
    }
}

struct ChartMediumPlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChartMediumPlaceholderView()
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
