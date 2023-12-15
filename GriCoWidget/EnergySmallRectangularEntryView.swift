//
//  IndicatorRectangularEntryView.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.01.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import SwiftUI

struct EnergySmallRectangularEntryView: View {
    let entry: EnergySmallEntry
    
    var body: some View {
        
        VStack(spacing: 2) {
            Text(entry.configuration.widget?.title ?? "💡").previewLayout(.sizeThatFits)
            HStack(spacing: 4) {
                Text(entry.mesurementValueToday.getScaledValue().0).font(.system(.headline, weight: .bold)).previewLayout(.sizeThatFits)
                Text(entry.mesurementValueToday.getScaledValue().1).font(.body).previewLayout(.sizeThatFits)
            }
            HStack(spacing: 4) {
                Text(entry.mesurementValueYesterday.getScaledValue().0).font(.system(.headline, weight: .bold)).previewLayout(.sizeThatFits)
                Text(entry.mesurementValueYesterday.getScaledValue().1).font(.body).previewLayout(.sizeThatFits)
            }
        }.containerBackground(for: .widget){}
    }
}
