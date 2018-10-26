//
//  ComplicationController.swift
//  JanOnVal WatchKit Extension
//
//  Created by Andreas Müller on 18.02.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import WatchKit
import ClockKit
import Foundation

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    let defaults = UserDefaults.standard
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        if complication.family == .modularSmall {
//            let template = CLKComplicationTemplateModularSmallRingText()
//            template.textProvider = CLKSimpleTextProvider(text: "J")
//            template.fillFraction = 0.5
            let template = CLKComplicationTemplateModularSmallSimpleImage()
            template.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "J_modular_small"))
            handler(template)
        } else if complication.family == .graphicCircular {
            //            let template = CLKComplicationTemplateModularSmallRingText()
            //            template.textProvider = CLKSimpleTextProvider(text: "J")
            //            template.fillFraction = 0.5
            let template = CLKComplicationTemplateGraphicCircularImage()
            template.imageProvider = CLKFullColorImageProvider(fullColorImage: #imageLiteral(resourceName: "J_circular"))
            handler(template)
        } else if complication.family == .utilitarianSmall {
            let template = CLKComplicationTemplateUtilitarianSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: "J")
            template.fillFraction = 0.5
            handler(template)
        } else if complication.family == .extraLarge {
//            let template = CLKComplicationTemplateExtraLargeStackImage()
//            template.highlightLine2 = true
//            template.line2TextProvider = CLKSimpleTextProvider(text: "1.2 kW")
//            template.line1ImageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "val135"))
            let template = CLKComplicationTemplateExtraLargeSimpleImage()
            template.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "J_x_large"))
            handler(template)
        } else {
            handler(nil)
        }
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        switch complication.family {
            
        case .modularSmall:
//            let template = CLKComplicationTemplateModularSmallRingText()
//            template.textProvider = CLKSimpleTextProvider(text: "J")
//            template.fillFraction = 1.0
            
            let template = CLKComplicationTemplateModularSmallSimpleImage()
            template.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "J_modular_small"))
            
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            break
        case .graphicCircular:
            //            let template = CLKComplicationTemplateModularSmallRingText()
            //            template.textProvider = CLKSimpleTextProvider(text: "J")
            //            template.fillFraction = 1.0
            
            let template = CLKComplicationTemplateGraphicCircularImage()
            template.imageProvider = CLKFullColorImageProvider(fullColorImage: #imageLiteral(resourceName: "J_circular"))
            
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            break
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: "J")
            template.fillFraction = 1.0
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            break
        case .extraLarge:
            /*setComplicationTimer()
            
            let unit = defaults.string(forKey: "UNIT") as! String
            var valueStr = ""
            if let v = defaults.double(forKey: "VAL") as? Double {
                let (si, normedV) = TableUtil.getSiPrefix(v)
                valueStr = String(format: "%.1f \(si)\(unit)", normedV)
            }
            
            let template = CLKComplicationTemplateExtraLargeStackImage()
            template.highlightLine2 = true
            template.line2TextProvider = CLKSimpleTextProvider(text: "\(valueStr)")
            
//            let date = Date()
//            let calendar = Calendar.current
//
//            let seconds = calendar.component(.second, from: date)
            
            if count % 2 == 0 {
                template.line1ImageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "val0"))
            } else {
                template.line1ImageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "val45"))
            }*/
            
            let template = CLKComplicationTemplateExtraLargeSimpleImage()
            template.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "J_x_large"))
            
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            break
        default:
            NSLog("%@", "Unknown complication type: \(complication.family)")
            handler(nil)
        }
    }
}
