//
//  IndicatorEntryView.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.01.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import SwiftUI

struct IndicatorEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    @State var entry: IndicatorEntry
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            ZStack{
                RadialGradient(gradient: Gradient(colors: [
                    Color(red: 143/255.0, green: 172/255.0, blue: 202/255.0, opacity:1.0),
                    Color(red: 69.0/255.0, green: 116.0/255.0, blue: 167/255.0, opacity:1.0)]),
                               center: .top, startRadius: 0, endRadius: 200)
                VStack(alignment: .center, spacing: 2) {
                    Text(entry.configuration.indicatorWidgetData?.title ?? "💡")
                        .font(.largeTitle)
                    HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 8) {
                        Text(entry.mesurementValue.getScaledValue().0).font(.system(.title2, design: .default)).bold().foregroundColor(.white)
                        Text(entry.mesurementValue.getScaledValue().1).font(.system(.title2, design: .default)).bold().foregroundColor(.white)
                    }
                    Text(entry.mesurementValue.getDateTimeFormatted()).font(.system(.caption2, design: .default)).foregroundColor(.white)
                }
            }
        case .accessoryInline:
            IndicatorInlineEntryView(entry: entry)
        case .accessoryRectangular:
            IndicatorRectangularEntryView(entry: entry)
        case .accessoryCircular:
            IndicatorRectangularEntryView(entry: entry.setDigsOnMV(d: 0))
        @unknown default:
            Text("Not implemented")
        }
    }
}
