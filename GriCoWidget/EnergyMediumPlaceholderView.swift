//
//  EnergyMediumPlaceholderView.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.02.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import SwiftUI
import WidgetKit

struct EnergyMediumPlaceholderView: View {
    var body: some View {
        EnergyMediumEntryView(entry: EnergyMediumEntry(configuration: ComparisonMediumIntent(), date: Date(),
                                                       firstWidgetMVToday: MeasurementValue(date: Date(), value: 689887987.234, unit: "Wh"),
                                                       firstWidgetMVYesterday: MeasurementValue(date: Date(), value: 689887987.234, unit: "Wh"),
                                                       secondWidgetMVToday: MeasurementValue(date: Date(), value: 689887987.234, unit: "W"),
                                                       secondWidgetMVYesterday: MeasurementValue(date: Date(), value: 689887987.234, unit: "W")))
    }
}

struct EnergyMediumPlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        EnergyMediumPlaceholderView()
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
