//
//  ComplicationController.swift
//  JanOnVal WatchKit Extension
//
//  Created by Andreas Müller on 18.02.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import WatchKit
import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        if complication.family == .modularSmall {
            let template = CLKComplicationTemplateModularSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: "J")
            template.fillFraction = 0.5
            handler(template)
        } else if complication.family == .utilitarianSmall {
            let template = CLKComplicationTemplateUtilitarianSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: "J")
            template.fillFraction = 0.5
            handler(template)
        } else {
            handler(nil)
        }
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        switch complication.family {
            
        case .modularSmall:
//            let template = CLKComplicationTemplateModularSmallRingText()
//            template.textProvider = CLKSimpleTextProvider(text: "")
//            template.fillFraction = 1.0
//            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            
            let template = CLKComplicationTemplateModularSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: "J")
            template.fillFraction = 1.0
            
//            let template = CLKComplicationTemplateModularSmallSimpleImage()
//            template.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Complication/Modular"))
            
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            break
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: "J")
            template.fillFraction = 1.0
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            break
        default:
            NSLog("%@", "Unknown complication type: \(complication.family)")
            handler(nil)
        }
    }
    

}
