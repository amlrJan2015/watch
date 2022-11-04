//
//  IndicatorCircularEntryView.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.01.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import SwiftUI

struct EnergySmallCircularEntryView: View {
    let entry: EnergySmallEntry
    
    var body: some View {
        
        VStack(spacing: 1) {
            Text(entry.configuration.widget?.title ?? "💡").font(.caption).previewLayout(.sizeThatFits)
            HStack(spacing: 2) {
                Text(entry.mesurementValueToday.getScaledValue().0).font(.system(.caption, weight: .bold)).previewLayout(.sizeThatFits)
                Text(entry.mesurementValueToday.getScaledValue().1).font(.caption).previewLayout(.sizeThatFits)
            }
            HStack(spacing: 2) {
                Text(entry.mesurementValueYesterday.getScaledValue().0).font(.system(.caption, weight: .bold)).previewLayout(.sizeThatFits)
                Text(entry.mesurementValueYesterday.getScaledValue().1).font(.caption).previewLayout(.sizeThatFits)
            }
        }
    }
}
