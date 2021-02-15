//
//  EnergyMediumEntryView.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.02.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//
import SwiftUI

struct EnergyMediumEntryView: View {
    
    let entry: EnergyMediumEntry
    
    var body: some View {
        
        if entry.configuration.viewMode == ViewModeList.twoWidgets {
            ZStack{
                RadialGradient(gradient: Gradient(colors: [
                                                    Color(red: 143/255.0, green: 172/255.0, blue: 202/255.0, opacity:1.0),
                                                    Color(red: 69.0/255.0, green: 116.0/255.0, blue: 167/255.0, opacity:1.0)]),
                               center: .top, startRadius: 0, endRadius: 200)
                
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 36) {
                    FirstWidgetView(entry: entry)
                    SecondWidgetView(entry: entry)
                }
                .padding(5.0)
            }
        } else {
            ZStack{
                RadialGradient(gradient: Gradient(colors: [
                                                    Color(red: 143/255.0, green: 172/255.0, blue: 202/255.0, opacity:1.0),
                                                    Color(red: 69.0/255.0, green: 116.0/255.0, blue: 167/255.0, opacity:1.0)]),
                               center: .top, startRadius: 0, endRadius: 200)
                /*Energy*/
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 10) {
                    FirstWidgetView(entry: entry)
                    HStack{
                        /*Extended Comparison*/
                        VStack(alignment: .trailing, spacing: 2) {
                            
                            let arr = ["CW", "LW", "CM", "LM", "CY", "LY"]
                            let arrLastYear = ["CW", "LYW", "CM", "LYM", "CY", "LY"]
                            
                            ForEach((0..<arr.count), id: \.self) { idx in
                                HStack{
                                    Text( ViewModeList.extendedComparisonLastYear == entry.configuration.viewMode ? arrLastYear[idx] :  arr[idx]).font(.system(.body, design: .monospaced)).foregroundColor(.white)
                                }
                                if idx != (arr.count - 1) {
                                    Divider()
                                }
                            }
                        }.fixedSize()
                        Divider()
                        VStack(alignment: .leading, spacing: 2) {
                            
                            let arr = ["CW", "LW", "CM", "LM", "CY", "LY"]
                            
                            ForEach((0..<arr.count), id: \.self) { idx in
                                HStack{
                                    Text(entry.getScaledValueForExtendedComparison(index: idx).0).font(.system(.body, design: .default)).foregroundColor(.white).bold()
                                    Text(entry.getScaledValueForExtendedComparison(index: idx).1).font(.system(.footnote, design: .default)).foregroundColor(.white)
                                }
                                if idx != (arr.count - 1) {
                                    Divider()
                                }
                            }
                        }.fixedSize()
                        if entry.configuration.smartComparison ?? 0 == 1 {
                            Divider()
                            VStack(alignment: .leading, spacing: 2) {
                                
                                let arr = ["CW", "LW", "CM", "LM", "CY", "LY"]
                                
                                ForEach((0..<arr.count), id: \.self) { idx in
                                    HStack{if idx % 2 == 0 {
                                        Text("↑").font(.system(.body, design: .default)).foregroundColor(.white).rotationEffect(Angle(degrees: entry.getDegreesForValueTrend(index: idx)))
                                    } else {
                                        Text(" ").font(.system(.body, design: .default))
                                    }
                                    }
                                    if idx != (arr.count - 1) {
                                        Divider()
                                    }
                                }
                            }.fixedSize()
                        }
                    }
                }
                .padding(15)
            }
        }
    }    
}
