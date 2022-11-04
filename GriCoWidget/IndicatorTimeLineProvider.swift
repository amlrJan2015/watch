//
//  IndicatorTimeLineProvider.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.01.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import Foundation
import WidgetKit

struct IndicatorTimeLineProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> IndicatorEntry {
        return IndicatorEntry(configuration: IndicatorIntent(), date: Date(), mesurementValue: MeasurementValue(date: Date(), value: Double.nan, unit: "W"))
    }
    
    func getSnapshot(for configuration: IndicatorIntent, in context: Context, completion: @escaping (IndicatorEntry) -> Void) {
        let date = Date()
        var entry: IndicatorEntry
        if context.isPreview {
            entry = IndicatorEntry(configuration: configuration, date: date, mesurementValue: MeasurementValue(date: date, value: 123, unit: "W"))
        } else {
            entry = IndicatorEntry(configuration: configuration, date: date, mesurementValue: MeasurementValue(date: date, value: Double.nan, unit: "W"))
        }
        
        completion(entry)
    }
    
    func getTimeline(for configuration: IndicatorIntent, in context: Context, completion: @escaping (Timeline<IndicatorEntry>) -> Void) {
        // Create a timeline entry for "now."
        let currentDate = Date()
        
        // Create a date that's 5 minutes in the future.
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        
        MeasurementValueManager.fetchMeasurementValue(widget: configuration.indicatorWidgetData) { (mValue) in
            guard let valueOpt: MeasurementValue? = mValue else { return }
            
            if let value = valueOpt {
                
                //            let entry = QuoteEntry(date: currentDate, quote: q)
                //            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                //            completion(timeline)
                let entry = IndicatorEntry(configuration: configuration, date: currentDate, mesurementValue: MeasurementValue(date: currentDate, value: value.value, unit: value.unit))
                
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                completion(timeline)
            }
        }
    }
    
    typealias Entry = IndicatorEntry
    
    typealias Intent = IndicatorIntent
    
    
}
