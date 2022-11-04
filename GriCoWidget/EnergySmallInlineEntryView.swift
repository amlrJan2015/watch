//
//  EnergySmallInlineEntryView.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.01.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import SwiftUI

struct EnergySmallInlineEntryView: View {
    let entry: EnergySmallEntry
    
    var body: some View {
        Text("\(entry.configuration.widget?.title ?? "💡") \(entry.mesurementValueToday.getScaledValue().0) \(entry.mesurementValueToday.getScaledValue().1)").previewLayout(.sizeThatFits)
    }
}
