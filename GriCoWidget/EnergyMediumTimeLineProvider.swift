//
//  EnergyMediumTimeLineProvider.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.02.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import Foundation
import WidgetKit

struct EnergyMediumTimeLineProvider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> EnergyMediumEntry {
        let date = Date()
        return EnergyMediumEntry(configuration: ComparisonMediumIntent(), date: date,
                                 firstWidgetMVToday: MeasurementValue(date: date, value: Double.nan, unit: "Wh"),
                                 firstWidgetMVYesterday: MeasurementValue(date: Date(), value: Double.nan, unit: "Wh"),
                                 secondWidgetMVToday: MeasurementValue(date: date, value: Double.nan, unit: "Wh"),
                                 secondWidgetMVYesterday: MeasurementValue(date: date, value: Double.nan, unit: "Wh"),extendedComparisonValues: [Double.nan, Double.nan,Double.nan,Double.nan,Double.nan, Double.nan])
    }
    
    func getSnapshot(for configuration: ComparisonMediumIntent, in context: Context, completion: @escaping (EnergyMediumEntry) -> Void) {
        let date = Date()
        var entry:EnergyMediumEntry
        if context.isPreview {
            entry = EnergyMediumEntry(configuration: ComparisonMediumIntent(), date: date,
                                      firstWidgetMVToday: MeasurementValue(date: date, value: 1, unit: "Wh"),
                                      firstWidgetMVYesterday: MeasurementValue(date: Date(), value: 2, unit: "Wh"),
                                      secondWidgetMVToday: MeasurementValue(date: date, value: 3, unit: "Wh"),
                                      secondWidgetMVYesterday: MeasurementValue(date: date, value: 4, unit: "Wh"),extendedComparisonValues: [5,6,7,8,9,10])
        } else {
            entry = EnergyMediumEntry(configuration: ComparisonMediumIntent(), date: date,
                                      firstWidgetMVToday: MeasurementValue(date: date, value: Double.nan, unit: "Wh"),
                                      firstWidgetMVYesterday: MeasurementValue(date: Date(), value: Double.nan, unit: "Wh"),
                                      secondWidgetMVToday: MeasurementValue(date: date, value: Double.nan, unit: "Wh"),
                                      secondWidgetMVYesterday: MeasurementValue(date: date, value: Double.nan, unit: "Wh"),extendedComparisonValues: [Double.nan, Double.nan,Double.nan,Double.nan,Double.nan, Double.nan])
        }
        
        completion(entry)
    }
    
    func getTimeline(for configuration: ComparisonMediumIntent, in context: Context, completion: @escaping (Timeline<EnergyMediumEntry>) -> Void) {
        // Create a timeline entry for "now."
        let currentDate = Date()
        
        // Create a date that's 5 minutes in the future.
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        
        EnergyValueManager.fetchMediumEnergy(configuration: configuration) { (mValue) in
            guard let valueOpt: EnergyMediumEntry? = mValue else { return }
            
            if let entry = valueOpt {
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                completion(timeline)
            }
        }
    }
    
    
    typealias Entry = EnergyMediumEntry
    
    typealias Intent = ComparisonMediumIntent
    
}
