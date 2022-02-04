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
            let template = CLKComplicationTemplateModularSmallSimpleImage(imageProvider: CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "J_modular_small")))
            handler(template)
        } else if complication.family == .graphicCircular {
            //            let template = CLKComplicationTemplateModularSmallRingText()
            //            template.textProvider = CLKSimpleTextProvider(text: "J")
            //            template.fillFraction = 0.5
            let template = CLKComplicationTemplateGraphicCircularImage(imageProvider: CLKFullColorImageProvider(fullColorImage: #imageLiteral(resourceName: "J_circular")))
            handler(template)
        } else if complication.family == .utilitarianSmall {
            let template = CLKComplicationTemplateUtilitarianSmallRingText(textProvider: CLKSimpleTextProvider(text: "J"), fillFraction: 0.5, ringStyle: .open)
            handler(template)
        } else if complication.family == .extraLarge {
            //            let template = CLKComplicationTemplateExtraLargeStackImage()
            //            template.highlightLine2 = true
            //            template.line2TextProvider = CLKSimpleTextProvider(text: "1.2 kW")
            //            template.line1ImageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "val135"))
            let template = CLKComplicationTemplateExtraLargeSimpleImage(imageProvider: CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "J_x_large")))
            
            //            let template = CLKComplicationTemplateExtraLargeSimpleText()
            //            template.textProvider = CLKSimpleTextProvider(text: "?")
            
            
            handler(template)
        } else if complication.family == .modularLarge {
            let template = CLKComplicationTemplateModularLargeTable(headerTextProvider: CLKSimpleTextProvider(text: "GridVis Companion"), row1Column1TextProvider: CLKSimpleTextProvider(text: "💡"), row1Column2TextProvider: CLKSimpleTextProvider(text: "123.5 Wh"), row2Column1TextProvider: CLKSimpleTextProvider(text: "⚡️"), row2Column2TextProvider: CLKSimpleTextProvider(text: "123.5 W"))
            handler(template)
        } else if complication.family == .graphicRectangular {
            let template = CLKComplicationTemplateGraphicRectangularStandardBody(headerImageProvider: nil, headerTextProvider: CLKSimpleTextProvider(text: "Energy"), body1TextProvider: CLKSimpleTextProvider(text: "123.4"), body2TextProvider: CLKSimpleTextProvider(text: "Wh"))
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
            
            let template = CLKComplicationTemplateModularSmallSimpleImage(imageProvider: CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "J_modular_small")))
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            break
        case .graphicCircular:
            //            let template = CLKComplicationTemplateModularSmallRingText()
            //            template.textProvider = CLKSimpleTextProvider(text: "J")
            //            template.fillFraction = 1.0
            
            let template = CLKComplicationTemplateGraphicCircularImage(imageProvider: CLKFullColorImageProvider(fullColorImage: #imageLiteral(resourceName: "J_circular")))
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            break
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallRingText(textProvider: CLKSimpleTextProvider(text: "J"), fillFraction: 1.0, ringStyle: .open)
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
            let value = defaults.dictionary(forKey: "VALUE") ?? ["energy": "123.4","activePower": "123.4"]
            let template = CLKComplicationTemplateExtraLargeSimpleText(textProvider: CLKSimpleTextProvider(text: value["energy"] as! String))
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            break
        case .modularLarge:
            
            let value = defaults.dictionary(forKey: "VALUE") ?? ["energy": "123.4","activePower": "123.4"]
            
            let template = CLKComplicationTemplateModularLargeTable(headerImageProvider: CLKImageProvider(onePieceImage:#imageLiteral(resourceName: "J_circular")), headerTextProvider: CLKSimpleTextProvider(text: "GridVis Companion"), row1Column1TextProvider: CLKSimpleTextProvider(text: "💡"), row1Column2TextProvider: CLKSimpleTextProvider(text: "\(value["energy"] ?? "123.4") Wh"), row2Column1TextProvider: CLKSimpleTextProvider(text: "⚡️"), row2Column2TextProvider: CLKSimpleTextProvider(text: "\(value["activePower"] ?? "123.4") W"))
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
            break
        case .graphicRectangular:
            
            let value = defaults.dictionary(forKey: "VALUE") ?? ["energy": "123.4","activePower": "123.4"]
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM HH:mm"
            
            let template = CLKComplicationTemplateGraphicRectangularStandardBody(headerTextProvider: CLKSimpleTextProvider(text: "Energy \(dateFormatter.string(from: date))"), body1TextProvider: CLKSimpleTextProvider(text: "\(value["energy"] ?? "123.4")"), body2TextProvider: CLKSimpleTextProvider(text: "Wh"))
            handler(CLKComplicationTimelineEntry(date: date, complicationTemplate: template))
            break
        default:
            NSLog("%@", "Unknown complication type: \(complication.family)")
            handler(nil)
        }
    }
}
