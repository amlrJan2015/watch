//
//  EnergySmallTimeLineProvider.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.02.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import Foundation
import WidgetKit

struct EnergySmallTimeLineProvider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> EnergySmallEntry {
        return EnergySmallEntry(configuration: ComparisonSmallIntent(), date: Date(),
                                mesurementValueToday: MeasurementValue(date: Date(), value: 123.0, unit: "W"),
                                mesurementValueYesterday: MeasurementValue(date: Date(), value: 123.0, unit: "W"))
    }
    
    func getSnapshot(for configuration: ComparisonSmallIntent, in context: Context, completion: @escaping (EnergySmallEntry) -> Void) {
        let date = Date()
        let entry = EnergySmallEntry(configuration: ComparisonSmallIntent(), date: date,
                                     mesurementValueToday: MeasurementValue(date: date, value: 123.0, unit: "W"),
                                     mesurementValueYesterday: MeasurementValue(date: date, value: 123.0, unit: "W"))
        
        completion(entry)
    }
    
    func getTimeline(for configuration: ComparisonSmallIntent, in context: Context, completion: @escaping (Timeline<EnergySmallEntry>) -> Void) {
        // Create a timeline entry for "now."
        let currentDate = Date()
        
        // Create a date that's 5 minutes in the future.
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        
        EnergyValueManager.fetchSmallEnergy(configuration: configuration) { (mValue) in
            guard let valueOpt: EnergySmallEntry? = mValue else { return }
            
            if let entry = valueOpt {
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                completion(timeline)
            }
        }
    }
    
    
    typealias Entry = EnergySmallEntry
    
    typealias Intent = ComparisonSmallIntent
    
}
