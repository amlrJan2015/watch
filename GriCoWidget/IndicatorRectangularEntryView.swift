//
//  IndicatorRectangularEntryView.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.01.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import SwiftUI

struct IndicatorRectangularEntryView: View {
    let entry: IndicatorEntry
    
    var body: some View {
        
        VStack(spacing: 2) {
            Text(entry.configuration.indicatorWidgetData?.title ?? "💡").previewLayout(.sizeThatFits)
            HStack(spacing: 6) {
                Text(entry.mesurementValue.getScaledValue().0).font(.system(.headline, weight: .bold)).previewLayout(.sizeThatFits)
                Text(entry.mesurementValue.getScaledValue().1).font(.body).previewLayout(.sizeThatFits)
            }
        }
    }
}
