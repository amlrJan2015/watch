//
//  IndicatorPlaceholderView.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.01.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import SwiftUI
import WidgetKit

struct IndicatorPlaceholderView: View {
    var body: some View {
        IndicatorEntryView(entry: IndicatorEntry(configuration: IndicatorIntent(), date: Date(), mesurementValue: MeasurementValue(date: Date(), value: 689887987.234, unit: "W")))
    }
}

struct IndicatorPlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        IndicatorPlaceholderView()
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
