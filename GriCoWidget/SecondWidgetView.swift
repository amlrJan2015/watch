//
//  SecondWidgetView.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.02.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import SwiftUI

struct SecondWidgetView: View {
    
    let entry: EnergyMediumEntry
    
    var body: some View {
        
        
        VStack(alignment: .center, spacing: 2) {
            
            HStack(alignment: .center, spacing: 0){
                Text(entry.configuration.secondWidget?.title ?? "🏭")
                    .font(.largeTitle)
                if entry.configuration.smartComparison ?? 0 == 1 {
                    Text("↑").font(.largeTitle).foregroundColor(.white).rotationEffect(Angle(degrees: entry.secondWidgetMVToday.getDegree(last: entry.secondWidgetMVYesterday.value)))
                }
            }
            
            VStack(alignment: .center) {
                Text("Today").font(.system(.footnote, design: .default)).foregroundColor(.white)
                HStack{
                    Text(entry.secondWidgetMVToday.getScaledValue().0).font(.system(.title, design: .default)).bold().foregroundColor(.white)
                    Text(entry.secondWidgetMVToday.getScaledValue().1).font(.system(.footnote, design: .default)).foregroundColor(.white)
                }
            }
            VStack(alignment: .center) {
                Text("Yesterday").font(.system(.footnote, design: .default)).foregroundColor(.white)
                HStack{
                    Text(entry.secondWidgetMVYesterday.getScaledValue().0).font(.system(.body, design: .default)).bold().foregroundColor(.white)
                    Text(entry.secondWidgetMVYesterday.getScaledValue().1).font(.system(.footnote, design: .default)).foregroundColor(.white)
                }
            }
            Text(entry.secondWidgetMVToday.getDateTimeFormatted()).font(.system(.caption2, design: .default)).foregroundColor(.white)
        }
    }
}
