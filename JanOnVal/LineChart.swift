//
//  Chart.swift
//  ChartsPlayGround
//
//  Created by Andreas M on 01.12.23.
//

import Charts
import SwiftUI

let todayData: [ChartData] = [
    .init(hour: Date(timeIntervalSince1970: 1701388800.0), activePower: 0.0),
    .init(hour: Date(timeIntervalSince1970: 1701392400.0), activePower: 0.0),
    .init(hour: Date(timeIntervalSince1970: 1701396000.0), activePower: 0.0),
    .init(hour: Date(timeIntervalSince1970: 1701399600.0), activePower: 0.0),
    .init(hour: Date(timeIntervalSince1970: 1701403200.0), activePower: 0.0),
    .init(hour: Date(timeIntervalSince1970: 1701406800.0), activePower: 0.0),
    .init(hour: Date(timeIntervalSince1970: 1701410400.0), activePower: 0.0),
    .init(hour: Date(timeIntervalSince1970: 1701414000.0), activePower: 8.0),
    .init(hour: Date(timeIntervalSince1970: 1701417600.0), activePower: -200.0),
    .init(hour: Date(timeIntervalSince1970: 1701421200.0), activePower: -1300.0),
    .init(hour: Date(timeIntervalSince1970: 1701424800.0), activePower: 2500.0),
    .init(hour: Date(timeIntervalSince1970: 1701428400.0), activePower: 4500.0),
    .init(hour: Date(timeIntervalSince1970: 1701432000.0), activePower: 7800.0),
    .init(hour: Date(timeIntervalSince1970: 1701435600.0), activePower: 8200.0),
    .init(hour: Date(timeIntervalSince1970: 1701439200.0), activePower: 8110.0),
    .init(hour: Date(timeIntervalSince1970: 1701442800.0), activePower: 7500.0),
    .init(hour: Date(timeIntervalSince1970: 1701446400.0), activePower: 6600.0),
    .init(hour: Date(timeIntervalSince1970: 1701450000.0), activePower: 5400.0),
    .init(hour: Date(timeIntervalSince1970: 1701453600.0), activePower: 1500.0),
    .init(hour: Date(timeIntervalSince1970: 1701457200.0), activePower: 200.0),
    .init(hour: Date(timeIntervalSince1970: 1701460800.0), activePower: 21.0),
    .init(hour: Date(timeIntervalSince1970: 1701464400.0), activePower: 0.0),
    .init(hour: Date(timeIntervalSince1970: 1701468000.0), activePower: 0.0),
    .init(hour: Date(timeIntervalSince1970: 1701471600.0), activePower: 0.0)
]

let yesterdayData: [ChartData] = [
    .init(hour: Date(timeIntervalSince1970: 1701388800.0), activePower: 0.0),
    .init(hour: Date(timeIntervalSince1970: 1701392400.0), activePower: 500.0),
    .init(hour: Date(timeIntervalSince1970: 1701396000.0), activePower: 1000.0),
    .init(hour: Date(timeIntervalSince1970: 1701397800.0), activePower: 2000.0),
    .init(hour: Date(timeIntervalSince1970: 1701399600.0), activePower: 500.0),
    .init(hour: Date(timeIntervalSince1970: 1701403200.0), activePower: 0.0),
    .init(hour: Date(timeIntervalSince1970: 1701406800.0), activePower: 0.0),
    .init(hour: Date(timeIntervalSince1970: 1701410400.0), activePower: 0.0),
    .init(hour: Date(timeIntervalSince1970: 1701414000.0), activePower: 8.0),
    .init(hour: Date(timeIntervalSince1970: 1701417600.0), activePower: -200.0),
    .init(hour: Date(timeIntervalSince1970: 1701421200.0), activePower: -2300.0),
    .init(hour: Date(timeIntervalSince1970: 1701424800.0), activePower: 5500.0),
    .init(hour: Date(timeIntervalSince1970: 1701428400.0), activePower: 4500.0),
    .init(hour: Date(timeIntervalSince1970: 1701432000.0), activePower: 2800.0),
    .init(hour: Date(timeIntervalSince1970: 1701435600.0), activePower: 7200.0),
    .init(hour: Date(timeIntervalSince1970: 1701439200.0), activePower: 7110.0),
    .init(hour: Date(timeIntervalSince1970: 1701442800.0), activePower: 4500.0),
    .init(hour: Date(timeIntervalSince1970: 1701446400.0), activePower: 4600.0),
    .init(hour: Date(timeIntervalSince1970: 1701450000.0), activePower: 3400.0),
    .init(hour: Date(timeIntervalSince1970: 1701453600.0), activePower: 500.0),
    .init(hour: Date(timeIntervalSince1970: 1701457200.0), activePower: 200.0),
    .init(hour: Date(timeIntervalSince1970: 1701460800.0), activePower: 21.0),
    .init(hour: Date(timeIntervalSince1970: 1701464400.0), activePower: 0.0),
    .init(hour: Date(timeIntervalSince1970: 1701468000.0), activePower: 0.0),
    .init(hour: Date(timeIntervalSince1970: 1701471600.0), activePower: 0.0)
]


/*let todayData: [PVChartData] = [
 .init(hour: 1, activePower: 2.0),
 .init(hour: 2, activePower: 2.0),
 .init(hour: 3, activePower: 3.0),
 .init(hour: 4, activePower: 4.0),
 .init(hour: 5, activePower: 5.0),
 .init(hour: 6, activePower: 6.0),
 .init(hour: 7, activePower: 7.0),
 .init(hour: 8, activePower: 18.0),
 .init(hour: 9, activePower: 19.0),
 .init(hour: 10, activePower: 20.0),
 .init(hour: 11, activePower: 21.0),
 .init(hour: 12, activePower: 32.0),
 .init(hour: 13, activePower: 33.0),
 .init(hour: 14, activePower: 34.0),
 .init(hour: 15, activePower: 25.0),
 .init(hour: 16, activePower: 26.0),
 .init(hour: 17, activePower: 17.0),
 .init(hour: 18, activePower: 8.0),
 .init(hour: 19, activePower: 9.0),
 .init(hour: 20, activePower: 2.0),
 .init(hour: 21, activePower: 1.0),
 .init(hour: 22, activePower: 0.0),
 .init(hour: 23, activePower: 0.0),
 .init(hour: 24, activePower: 0.0),
 ]
 
 let yesterdayData: [PVChartData] = [
 .init(hour: 1, activePower: 2.0),
 .init(hour: 2, activePower: 2.0),
 .init(hour: 3, activePower: 3.0),
 .init(hour: 4, activePower: 4.0),
 .init(hour: 5, activePower: 5.0),
 .init(hour: 6, activePower: 6.0),
 .init(hour: 7, activePower: 7.0),
 .init(hour: 8, activePower: 28.0),
 .init(hour: 9, activePower: 29.0),
 .init(hour: 10, activePower: 24.0),
 .init(hour: 11, activePower: 21.0),
 .init(hour: 12, activePower: 42.0),
 .init(hour: 13, activePower: 43.0),
 .init(hour: 14, activePower: 38.0),
 .init(hour: 15, activePower: 35.0),
 .init(hour: 16, activePower: 36.0),
 .init(hour: 17, activePower: 27.0),
 .init(hour: 18, activePower: 18.0),
 .init(hour: 19, activePower: 19.0),
 .init(hour: 20, activePower: 12.0),
 .init(hour: 21, activePower: 11.0),
 .init(hour: 22, activePower: 0.0),
 .init(hour: 23, activePower: 0.0),
 .init(hour: 24, activePower: 0.0),
 ]*/

var sd1 = ChartDataSeries(timePeriod: "Today", pvData: todayData, min: -1300.0, max: 8200.0)
var sd2 = ChartDataSeries(timePeriod: "Yesterday", pvData: yesterdayData, min: -2300.0, max: 7200.0)

let seriesData: [ChartDataSeries] = [
    sd1,
    sd2
]

struct LineChart: View {
    @Environment(\.calendar) var calendar
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    let name: String
    let unit: String
    let seriesData: [ChartDataSeries]
    @State var rawSelectedDate: Date?
    
    var body: some View {
        VStack {
            Spacer()
            Text(name)
                .font(.largeTitle .bold())
                .foregroundColor(.indigo)
                .padding()
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                }.help("Close")
            Text(" ").padding()
            
            if seriesData.count == 2 {
                Chart(seriesData) { series in
                    ForEach(series.pvData) { element in
                        LineMark(
                            x: .value("Time", element.hour),
                            y: .value("Leistung", element.activePower)
                        )
                        .foregroundStyle(by: .value("TimePeriod", series.timePeriod))
                        //.symbol(by: .value("Time", series.timePeriod))
                        .interpolationMethod(.catmullRom)
                    }
                    if let selectedDate = rawSelectedDate {
                        RuleMark(
                            x: .value("Selected", selectedDate)
                        )
                        .foregroundStyle(Color.yellow.opacity(0.5))
                        .offset(yStart: -10)
                        .zIndex(-1)
                        .annotation(
                            position: .top, spacing: 0,
                            overflowResolution: .init(
                                x: .fit(to: .chart),
                                y: .disabled
                            )
                        ) {
                            valueSelectionPopover
                        }
                    }
                }
                .chartForegroundStyleScale([
                    "Yesterday": .gray,
                    "Today": .blue
                ])
                .chartYScale(domain: Int(Swift.min(seriesData[0].min!, seriesData[1].min!)) ... Int(Swift.max(seriesData[0].max!, seriesData[1].max!) + (Swift.max(seriesData[0].max!, seriesData[1].max!) - Swift.min(seriesData[0].min!, seriesData[1].min!)) * 0.05 ))
                .chartXSelection(value: $rawSelectedDate)
                .chartYAxis{
                    AxisMarks(values: .automatic(desiredCount: 10))
                }
                .chartXAxis{
                    AxisMarks(values: .automatic(desiredCount: 12))
                }
                .padding()
                
            } else {
                Text("⌛️(no data)").font(.largeTitle)
            }
        }
    }
    
    @ViewBuilder
    var valueSelectionPopover: some View {
        if let rawSelectedDate,
           let valuesPerTimePeriod = valuesPerTimePeriod(on: rawSelectedDate) {
            VStack(alignment: .leading) {
                Text("Date: \(LineChart.getDateTimeFormatted(date: rawSelectedDate))")
                 .font(preTitleFont)
                 .foregroundStyle(.secondary)
                 .fixedSize()
                HStack(spacing: 20) {
                    ForEach(valuesPerTimePeriod) { data in
                        VStack(alignment: .leading, spacing: 1) {
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                if let v = data.value {
                                    Text(String(format: "%.1f", v))
                                        .font(titleFont)
                                        .foregroundColor(colorScheme == .light ? .black : .white)
                                        .blendMode(colorScheme == .light ? .plusDarker : .normal)
                                    Text(unit)
                                        .font(titleFont)
                                        .foregroundColor(colorScheme == .light ? .black : .white)
                                        .blendMode(colorScheme == .light ? .plusDarker : .normal)
                                } else {
                                    Text(" ")
                                        .font(titleFont)
                                        .foregroundColor(.black)
                                        .blendMode(colorScheme == .light ? .plusDarker : .normal)
                                }
                                
                            }
                            HStack(spacing: 6) {
                                if data.timeperiod == "Today" {
                                    legendCircle
                                } else {
                                    legendSquare
                                }
                                Text("\(data.timeperiod)")
                                    .font(labelFont)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .padding(6)
            .background {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(Color.gray.opacity(0.12))
            }
        } else {
            EmptyView()
        }
    }
    
    struct ValuePerTimeperiod: Identifiable {
        var timeperiod: String
        var value: Double?
        var id: String { timeperiod }
    }
    
    func valuesPerTimePeriod(on selectedDate: Date) -> [ValuePerTimeperiod]? {
        
        let seriesIndex = seriesData[0].pvData.count >= seriesData[1].pvData.count ? 0 : 1
        
        let index = seriesData[seriesIndex].pvData.firstIndex(where: { chartData in
            Swift.abs(chartData.hour.timeIntervalSince(selectedDate)) < (10 * 60)
        })
                
        if index == nil {
            return nil
        }
        
        return seriesData.map {
            return ValuePerTimeperiod(timeperiod: $0.timePeriod, value: index! < $0.pvData.count ? $0.pvData[index!].activePower : nil)
        }
    }
    
    public static func getDateTimeFormatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        //formatter.setLocalizedDateFormatFromTemplate("dd.MM.yy HH:mm:ss")
        return formatter.string(for: date) ?? ""
    }
}

@ViewBuilder
var legendSquare: some View {
    RoundedRectangle(cornerRadius: 1)
        .stroke(lineWidth: 2)
        .frame(width: 5.3, height: 5.3)
        .foregroundColor(.green)
        .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 0))
}

@ViewBuilder
var legendCircle: some View {
    Circle()
        .stroke(lineWidth: 2)
        .frame(width: 5.7, height: 5.7)
        .foregroundColor(.purple)
        .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 0))
}

#if os(macOS)
var titleFont: Font = .title.bold()
#else
var titleFont: Font = .title2.bold()
#endif

#if os(macOS)
var preTitleFont: Font = .headline
#else
var preTitleFont: Font = .callout
#endif

#if os(macOS)
var labelFont: Font = .subheadline
#else
var labelFont: Font = .caption2
#endif

#if os(macOS)
var descriptionFont: Font = .body
#else
var descriptionFont: Font = .subheadline
#endif

#Preview {
    LineChart(name: "Test", unit: "W", seriesData: seriesData, rawSelectedDate: Date(timeIntervalSince1970: 1701428400.0))
}
