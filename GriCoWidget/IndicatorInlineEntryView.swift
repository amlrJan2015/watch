//
//  IndicatorInlineEntryView.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.01.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import SwiftUI

struct IndicatorInlineEntryView: View {
    let entry: IndicatorEntry
    
    var body: some View {
        Text("\(entry.configuration.indicatorWidgetData?.title ?? "💡") \(entry.mesurementValue.getScaledValue().0) \(entry.mesurementValue.getScaledValue().1)").previewLayout(.sizeThatFits)
    }
}
