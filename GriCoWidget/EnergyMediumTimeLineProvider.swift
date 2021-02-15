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
                                firstWidgetMVToday: MeasurementValue(date: date, value: 123.0, unit: "W"),
                                firstWidgetMVYesterday: MeasurementValue(date: Date(), value: 123.0, unit: "W"),
                                secondWidgetMVToday: MeasurementValue(date: date, value: 123.0, unit: "W"),
                                secondWidgetMVYesterday: MeasurementValue(date: date, value: 123.0, unit: "W"),extendedComparisonValues: [123.0, 123.0,123.0,123.0,123.0, 123.0])
    }
    
    func getSnapshot(for configuration: ComparisonMediumIntent, in context: Context, completion: @escaping (EnergyMediumEntry) -> Void) {
        let date = Date()
        let entry = EnergyMediumEntry(configuration: ComparisonMediumIntent(), date: date,
                                      firstWidgetMVToday: MeasurementValue(date: date, value: 123.0, unit: "W"),
                                      firstWidgetMVYesterday: MeasurementValue(date: Date(), value: 123.0, unit: "W"),
                                      secondWidgetMVToday: MeasurementValue(date: date, value: 123.0, unit: "W"),
                                      secondWidgetMVYesterday: MeasurementValue(date: date, value: 123.0, unit: "W"),extendedComparisonValues: [123.0, 123.0,123.0,123.0,123.0, 123.0])
        
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
