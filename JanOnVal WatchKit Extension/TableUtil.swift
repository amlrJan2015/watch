//
//  TableUtil.swift
//  JanOnVal WatchKit Extension
//
//  Created by Andreas Müller on 21.02.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import WatchKit
import Foundation

class TableUtil {
    private static func logC(val: Double, forBase base: Double) -> Double {
        return log(val)/log(base)
    }    
    
    public static func getSiPrefix(_ value: Double) -> (String, Double) {
        var result = ("",value)
        
        let pow10 = logC(val: value, forBase: 10.0)
        
        if pow10 >= 3.0 {
            result = ("k", value / 1000.0)
        }
        if pow10 >= 6.0 {
            result = ("M", value / 1000_000.0)
        }
        
        return result
    }
    
    public static func showHistEnergyValueInTable(_ json: [String : AnyObject], _ measurementData: [String: Any], _ table: WKInterfaceTable, tableRowIndex index: Int) {
        let unit = measurementData["unit"] as! String
        let unit2 = measurementData["unit2"] as! String
        let title = measurementData["watchTitle"] as! String
        
        if let value = json["energy"] as? Double {
            DispatchQueue.main.async { // Correct
                let row = table.rowController(at: index) as? MeasurementRowType
                
                let (si, newValue) = getSiPrefix(value)
                
                row?.value.setText(String(format:"%.1f", newValue))
                row?.unit.setText(si+("" == unit2 ? unit : unit2))
                row?.header.setText(title)
            }
        } else {
            DispatchQueue.main.async { // Correct
                let row = table.rowController(at: index) as? MeasurementRowType
                row?.value.setText("NaN")
                row?.unit.setText(("" == unit2 ? unit : unit2))
                row?.header.setText(title)
            }
        }
    }
}
