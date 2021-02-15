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
        EnergySmallEntryView(entry: EnergySmallEntry(configuration: ComparisonSmallIntent(), date: Date(), mesurementValueToday: MeasurementValue(date: Date(), value: 689887987.234, unit: "W"), mesurementValueYesterday: MeasurementValue(date: Date(), value: 689887987.234, unit: "W")))
    }
}

struct EnergySmallPlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        EnergySmallPlaceholderView()
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
