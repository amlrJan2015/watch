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
            
            //            let template = CLKComplicationTemplateExtraLargeSimpleText()
            //            template.textProvider = CLKSimpleTextProvider(text: "?")
            
            
            handler(template)
        } else if complication.family == .modularLarge {
            let template = CLKComplicationTemplateModularLargeTable()
            template.headerTextProvider = CLKSimpleTextProvider(text: "GridVis Companion")
            template.row1Column1TextProvider = CLKSimpleTextProvider(text: "💡")
            template.row1Column2TextProvider = CLKSimpleTextProvider(text: "123.5 Wh")
            template.row2Column1TextProvider = CLKSimpleTextProvider(text: "⚡️")
            template.row2Column2TextProvider = CLKSimpleTextProvider(text: "123.5 W")
            handler(template)
        } else if complication.family == .graphicRectangular {
            let template = CLKComplicationTemplateGraphicRectangularStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "Energy")
            template.body1TextProvider = CLKSimpleTextProvider(text: "123.4")
            template.body2TextProvider = CLKSimpleTextProvider(text: "Wh")
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
            
            //            let template = CLKComplicationTemplateExtraLargeSimpleImage()
            //            template.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "J_x_large"))
            //
            //            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            let template = CLKComplicationTemplateExtraLargeSimpleText()
            
            
            let value = defaults.dictionary(forKey: "VALUE") ?? ["energy": "123.4","activePower": "123.4"]
            
            template.textProvider = CLKSimpleTextProvider(text: value["energy"] as! String)
            
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            break
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeTable()
            
            
            let value = defaults.dictionary(forKey: "VALUE") ?? ["energy": "123.4","activePower": "123.4"]
            
            template.headerTextProvider = CLKSimpleTextProvider(text: "GridVis Companion")
            template.headerImageProvider = CLKImageProvider(onePieceImage:#imageLiteral(resourceName: "J_circular"))
            
            template.row1Column1TextProvider = CLKSimpleTextProvider(text: "💡")
            template.row1Column2TextProvider = CLKSimpleTextProvider(text: "\(value["energy"] ?? "123.4") Wh")
            
            template.row2Column1TextProvider = CLKSimpleTextProvider(text: "⚡️")
            template.row2Column2TextProvider = CLKSimpleTextProvider(text: "\(value["activePower"] ?? "123.4") W")
            
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            break
        case .graphicRectangular:
            let template = CLKComplicationTemplateGraphicRectangularStandardBody()
            
            
            let value = defaults.dictionary(forKey: "VALUE") ?? ["energy": "123.4","activePower": "123.4"]
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM HH:mm"
            template.headerTextProvider = CLKSimpleTextProvider(text: "Energy \(dateFormatter.string(from: date))")
            template.body1TextProvider = CLKSimpleTextProvider(text: "\(value["energy"] ?? "123.4")")
            template.body2TextProvider = CLKSimpleTextProvider(text: "Wh")
            
            handler(CLKComplicationTimelineEntry(date: date, complicationTemplate: template))
            break
        default:
            NSLog("%@", "Unknown complication type: \(complication.family)")
            handler(nil)
        }
    }
}
