//
//  EnergyMediumEntryView.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.02.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//
import SwiftUI
import WidgetKit

private extension ChartMediumEntryView {
    func monthAbbreviation(_ monthIndex: Int) -> String {
        Calendar.current.veryShortMonthSymbols[monthIndex]
    }
}


struct ChartMediumEntryView: View {
    
    let entry: ChartMediumEntry
    
    var body: some View {
        
        ZStack{
            RadialGradient(gradient: Gradient(colors: [
                Color(red: 143/255.0, green: 172/255.0, blue: 202/255.0, opacity:1.0),
                Color(red: 69.0/255.0, green: 116.0/255.0, blue: 167/255.0, opacity:1.0)]),
                           center: .top, startRadius: 0, endRadius: 200)
            HStack {
                VStack{
                    Spacer()
                    Text(String(entry.getScaleValues()[0]))
                        .font(.caption2)
                        .padding(.bottom, 8.0)
                        .padding(.leading, 4.0)
                        .frame(width: 40.0)
                        .foregroundColor(Color(red: 35/255.0, green: 58/255.0, blue: 84/255.0, opacity:1.0))
                    Text(String(entry.getScaleValues()[1]))
                        .font(.caption2)
                        .padding(.bottom, 8.0)
                        .padding(.leading, 4.0)
                        .frame(width: 40.0)
                        .foregroundColor(Color(red: 35/255.0, green: 58/255.0, blue: 84/255.0, opacity:1.0))
                    Text(String(entry.getScaleValues()[2]))
                        .font(.caption2)
                        .padding(.bottom, 8.0)
                        .padding(.leading, 4.0)
                        .frame(width: 40.0)
                        .foregroundColor(Color(red: 35/255.0, green: 58/255.0, blue: 84/255.0, opacity:1.0))
                    Text(String(entry.getScaleValues()[3]))
                        .font(.caption2)
                        .padding(.bottom, 8.0)
                        .padding(.leading, 4.0)
                        .frame(width: 40.0)
                        .foregroundColor(Color(red: 35/255.0, green: 58/255.0, blue: 84/255.0, opacity:1.0))
                    Text("kWh")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.bottom, 12.0)
                        .padding(.leading, 4.0)
                        .frame(width: 40.0)
                        .foregroundColor(Color(red: 35/255.0, green: 58/255.0, blue: 84/255.0, opacity:1.0))
                }
//                Spacer()
                /*Energy current year*/
                ZStack {
                    
                    HStack {
                        ForEach(0..<12) { monthIndex in
                            VStack {
                                Spacer()
                                Rectangle()
                                    .fill(Color.yellow)
                                    .frame(
                                        width: 15,
                                        height: entry.getYearlyValues(currentYearlyValues: entry.currentYearlyValues)[monthIndex]
                                    )
                                    .cornerRadius(1.8)
                                Text("\(monthAbbreviation(monthIndex))")
                                    .font(.caption2)
                                    .padding(.bottom, 8.0)
                                    .frame(height: 8.0)
                                    .foregroundColor(Color(red: 35/255.0, green: 58/255.0, blue: 84/255.0, opacity:1.0))
                            }
                        }
                    }.zIndex(3)
                    /*Energy last year*/
                    HStack {
                        ForEach(0..<12) { monthIndex in
                            VStack {
                                Spacer()
                                Rectangle()
                                    .fill(Color.orange)
                                    .frame(
                                        width: 15,
                                        height: entry.getYearlyValues(currentYearlyValues: entry.lastYearlyValues)[monthIndex]
                                    )
                                    .cornerRadius(1.8)
                                    .opacity(0.8)
                                Text("")
                                    .font(.caption2)
                                    .padding(.bottom, 8.0)
                                    .frame(height: 8.0)
                            }
                        }
                    }
                    .zIndex(2)
                    .offset(x: 5, y: 0)
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(Color.white)
                            .frame(height: 0.6)
                            .padding(.bottom, 21.0)
                            .opacity(0.6)
                        Rectangle()
                            .fill(Color.white)
                            .frame(height: 0.6)
                            .padding(.bottom, 21.0)
                            .opacity(0.6)
                        Rectangle()
                            .fill(Color.white)
                            .frame(height: 0.6)
                            .padding(.bottom, 21.0)
                            .opacity(0.6)
                        Rectangle()
                            .fill(Color.white)
                            .frame(height: 0.6)
                            .padding(.bottom, 45.0)
                            .opacity(0.6)
                    }.zIndex(1)
                }
            }
            .padding(.trailing)
            
        }
        
    }
}

struct ChartMediumEntryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChartMediumPlaceholderView()
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
