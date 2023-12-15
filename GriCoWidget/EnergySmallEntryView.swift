//
//  EnergySmallEntryView.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.02.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import SwiftUI

struct EnergySmallEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    @State var entry: EnergySmallEntry
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            ZStack{
                //            Image("JWS").scaleEffect(CGSize(width: 0.024, height: 0.024)).position(x: 17.0, y: 20.0)
                HStack {
                    VStack(alignment: .center, spacing: 2) {
                        HStack(alignment: .center, spacing: 0){
                            Text(entry.configuration.widget?.title ?? "🏭")
                                .font(.largeTitle)
                            if entry.configuration.smartComparison ?? 0 == 1 {
                                Text("↑").font(.largeTitle).foregroundColor(.white).rotationEffect(Angle(degrees: entry.mesurementValueToday.getDegree(last: entry.mesurementValueYesterday.value)))
                            }
                        }
                        VStack(alignment: .center) {
                            Text("Today").font(.system(.footnote, design: .default)).bold().foregroundColor(.white)
                            HStack{
                                //                            .system(.title, design: .default)).bold()
                                //                            Text(entry.getScaledValueToday().0).font(.custom("AppleSDGothicNeo", size: 30))
                                Text(entry.mesurementValueToday.getScaledValue().0).font(.system(.title, design: .default)).bold().foregroundColor(.white)
                                Text(entry.mesurementValueToday.getScaledValue().1).font(.system(.footnote, design: .default)).foregroundColor(.white)
                            }
                        }
                        VStack(alignment: .center) {
                            Text("Yesterday").font(.system(.footnote, design: .default)).foregroundColor(.white)
                            HStack{
                                Text(entry.mesurementValueYesterday.getScaledValue().0).font(.system(.body, design: .default)).bold().foregroundColor(.white)
                                Text(entry.mesurementValueYesterday.getScaledValue().1).font(.system(.footnote, design: .default)).foregroundColor(.white)
                            }
                        }
                        Text(entry.mesurementValueToday.getDateTimeFormatted()).font(.system(.caption2, design: .default)).foregroundColor(.white)
                    }
                }
                .padding(5.0)
            }
            .edgesIgnoringSafeArea(.all)
            .containerBackground(for: .widget) {
                RadialGradient(gradient: Gradient(colors: [
                    Color(red: 143/255.0, green: 172/255.0, blue: 202/255.0, opacity:1.0),
                    Color(red: 69.0/255.0, green: 116.0/255.0, blue: 167/255.0, opacity:1.0)]),
                               center: .top, startRadius: 0, endRadius: 150)
            }
        case .accessoryInline:
            EnergySmallInlineEntryView(entry: entry)
        case .accessoryRectangular:
            EnergySmallRectangularEntryView(entry: entry)
        case .accessoryCircular:
            EnergySmallCircularEntryView(entry: entry.setDigsOnMVToday(d: 0))
        @unknown default:
            Text("Not implemented")
            
        }
    }
}

