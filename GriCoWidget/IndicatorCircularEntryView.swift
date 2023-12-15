//
//  IndicatorCircularEntryView.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.01.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import SwiftUI
import WidgetKit

struct IndicatorCircularEntryView: View {
    let entry: IndicatorEntry
    
    var body: some View {        
        VStack(spacing: 2) {
            Text(entry.configuration.indicatorWidgetData?.title ?? "💡").font(.caption).previewLayout(.sizeThatFits)
            HStack(spacing: 6) {
                Text(entry.mesurementValue.getScaledValue().0).font(.system(.caption, weight: .bold)).previewLayout(.sizeThatFits).previewLayout(.sizeThatFits)
                Text(entry.mesurementValue.getScaledValue().1).font(.caption).previewLayout(.sizeThatFits).previewLayout(.sizeThatFits)
            }
        }.containerBackground(for: .widget){}
    }
}
