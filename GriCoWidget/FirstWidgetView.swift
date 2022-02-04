//
//  FirstWidget.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.02.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import SwiftUI

struct FirstWidgetView: View {
    
    let entry: EnergyMediumEntry
    
    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            HStack(alignment: .center, spacing: 0){
                Text(entry.configuration.firstWidget?.title ?? "🏭")
                    .font(.largeTitle)
                if entry.configuration.smartComparison ?? 0 == 1 {
                    Text("↑").font(.largeTitle).foregroundColor(.white).rotationEffect(Angle(degrees: entry.firstWidgetMVToday.getDegree(last: entry.firstWidgetMVYesterday.value)))
                }
            }
            VStack(alignment: .center) {
                Text("Today").font(.system(.footnote, design: .default)).bold().foregroundColor(.white)
                HStack{
                    Text(entry.firstWidgetMVToday.getScaledValue().0).font(.system(.title, design: .default)).bold().foregroundColor(.white)
                    Text(entry.firstWidgetMVToday.getScaledValue().1).font(.system(.footnote, design: .default)).foregroundColor(.white)
                }
            }
            VStack(alignment: .center) {
                Text("Yesterday").font(.system(.footnote, design: .default)).foregroundColor(.white)
                HStack{
                    Text(entry.firstWidgetMVYesterday.getScaledValue().0).font(.system(.body, design: .default)).bold().foregroundColor(.white)
                    Text(entry.firstWidgetMVYesterday.getScaledValue().1).font(.system(.footnote, design: .default)).foregroundColor(.white)
                }
            }
            Text(entry.firstWidgetMVYesterday.getDateTimeFormatted()).font(.system(.caption2, design: .default)).foregroundColor(.white)
        }
    }
}
