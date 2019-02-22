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
    public static let ONLINE = 0, HIST = 1, MI = 2
    
    public static var VALUE_CACHE: [String:String] = [:]
    
    private static func logC(val: Double, forBase base: Double) -> Double {
        return log(val)/log(base)
    }    
    
    public static func getSiPrefix(_ value: Double) -> (String, Double) {
        var result = ("",value)
        
        let pow10 = round(logC(val: abs(value), forBase: 10.0)*100000)/100000
        
        
        if pow10 >= 3.0 {
            result = ("k", value / 1000.0)
        }
        if pow10 >= 6.0 {
            result = ("M", value / 1000_000.0)
        }
        if pow10 >= 9.0 {
            result = ("G", value / 1000_000_000.0)
        }
        if pow10 >= 12.0 {
            result = ("T", value / 1000_000_000_000.0)
        }
        
        return result
    }
    
    private static func log10round(_ value: Double) -> ( Double) {
        return round(logC(val: abs(value), forBase: 10.0)*100000)/100000
    }
    
    public static func getCompactNumberAndSiriPrefix(_ value: Double) -> String {
        var result = ("",value)
        
        let pow10 = log10round( abs(value))
    
    
        // Dies hier ist Ausnahme, weil 500 kuerzer ist als 0.5k
        // Ansonsten pow10 groesser gleich 2.0
        if pow10 >= 3.0 {
            result = ("k", value / 1000.0)
        }
        if pow10 >= 5.0 {
            result = ("M", value / 1000_000.0)
        }
        if pow10 >= 8.0 {
            result = ("G", value / 1000_000_000.0)
        }
        if pow10 >= 11.0 {
            result = ("T", value / 1000_000_000_000.0)
        }
        if pow10 <= -2.0 {
            result = ("m", value * 1000.0)
        }
        if pow10 <= -4.0 {
            result = ("µ", value * 1000_000.0)
        }
        if pow10 <= -7.0 {
            result = ("n", value * 1000_000_000.0)
        }
        if pow10 <= -10.0 {
            result = ("p", value * 1000_000_000_000.0)
        }
        
        var returnstring = String(format:"%.1f",result.1) + result.0
        
        if( ( abs(result.1) >= 10) || ((round( result.1 * 10) - 10 * round( result.1)) == 0)){
            returnstring = String(format:"%.0f",result.1) + result.0
         }
        
        return returnstring
    
    }
    
    private static func addValueCache(measurementValue: String, measurementType: String, deviceId: Int, value: String) {
        VALUE_CACHE["\(deviceId)|\(measurementValue)|\(measurementType)"] = value
    }
    
    public static func showHistEnergyValue(_ json: [String : AnyObject], _ measurementData: [String: Any], _ valueLbl: WKInterfaceLabel, _ unitLbl: WKInterfaceLabel, _ waitLbl: WKInterfaceLabel? = nil) {
        let unit = measurementData["unit"] as! String
        let unit2 = measurementData["unit2"] as! String
        let deviceId = measurementData["deviceId"] as! Int
        let measurementValue = measurementData["measurementValue"] as! String
        let measurementType = measurementData["measurementType"] as! String
        
        unitLbl.setText(("" == unit2 ? unit : unit2))
        
        if let value = json["energy"] as? Double {
            DispatchQueue.main.async { // Correct
                let (si, newValue) = getSiPrefix(value)
                let value: String = String(format:"%.1f", newValue)
                valueLbl.setText(value)
                waitLbl?.setText("")
                addValueCache(measurementValue: measurementValue, measurementType: measurementType, deviceId: deviceId, value: value)
                    unitLbl.setText(si+("" == unit2 ? unit : unit2))
            }
        } else {
            DispatchQueue.main.async { // Correct
                valueLbl.setText("NaN")
                waitLbl?.setText("")
            }
        }
    }
    
    public static func showHistEnergyValueInTable(_ json: [String : AnyObject], _ measurementData: [String: Any], _ table: WKInterfaceTable, tableRowIndex index: Int) {
        let unit = measurementData["unit"] as! String
        let unit2 = measurementData["unit2"] as! String
        let title = measurementData["watchTitle"] as! String
        let deviceId = measurementData["deviceId"] as! Int
        let measurementValue = measurementData["measurementValue"] as! String
        let measurementType = measurementData["measurementType"] as! String        
        
        if let value = json["energy"] as? Double {
            DispatchQueue.main.async { // Correct
                let (si, newValue) = getSiPrefix(value)
                if let row = table.rowController(at: index) as? MeasurementRowType {
                    let value: String = String(format:"%.1f", newValue)
                    row.value.setText(value)
                    addValueCache(measurementValue: measurementValue, measurementType: measurementType, deviceId: deviceId, value: value)
                    row.unit.setText(si+("" == unit2 ? unit : unit2))
                    row.header.setText(title)
                } else if let row = table.rowController(at: index) as? HistMeasurementRowType {
                    row.value.setText(String(format:"%.1f", newValue))
                    row.unit.setText(si+("" == unit2 ? unit : unit2))
                    switch index {
                        case 0: row.dateDesc.setText("H ")
                        case 1: row.dateDesc.setText("G ")
                        case 2: row.dateDesc.setText("DW")
                        case 3: row.dateDesc.setText("LW")
                        case 4: row.dateDesc.setText("DM")
                        case 5: row.dateDesc.setText("LM")
                        case 6: row.dateDesc.setText("DJ")
                        case 7: row.dateDesc.setText("LJ")
                        default: row.dateDesc.setText("??")
                    }
                }
            }
        } else {
            DispatchQueue.main.async { // Correct
                if let row = table.rowController(at: index) as? MeasurementRowType {
                    row.value.setText("NaN")
                    row.unit.setText(("" == unit2 ? unit : unit2))
                    row.header.setText(title)
                } else if let row = table.rowController(at: index) as? HistMeasurementRowType {
                    row.value.setText("NaN")
                    row.unit.setText(("" == unit2 ? unit : unit2))
                }
            }
        }
    }
    
    public static func showManualInputInTable(_ json: [String : AnyObject], _ measurementData: [String: Any],_ table: WKInterfaceTable, tableRowIndex index: Int) {
        let unit = measurementData["unit"] as! String
        let unit2 = measurementData["unit2"] as! String
        let deviceId = measurementData["deviceId"] as! Int
        let measurementValue = measurementData["measurementValue"] as! String
        let measurementType = measurementData["measurementType"] as! String
        
        let valmeasurement = json["details"] as? [String: Any]
        if let value = valmeasurement!["lastValue"] as? Double {
            DispatchQueue.main.async { // Correct
                let row = table.rowController(at: index) as? MeasurementRowType
                let (si, newValue) = TableUtil.getSiPrefix(value)
                let value: String = String(format:"%.1f", newValue)
                row?.value.setText(value)
                addValueCache(measurementValue: measurementValue, measurementType: measurementType, deviceId: deviceId, value: value)
                row?.unit.setText(si+("" == unit2 ? unit : unit2))
            }
        } else {
            DispatchQueue.main.async { // Correct
                let row = table.rowController(at: index) as? MeasurementRowType
                row?.value.setText("NaN")
                row?.unit.setText(("" == unit2 ? unit : unit2))
            }
        }
    }
    
    public static func showManualInput(_ json: [String : AnyObject], _ measurementData: [String: Any],_ valueLbl: WKInterfaceLabel, _ unitLbl: WKInterfaceLabel, _ waitLbl: WKInterfaceLabel? = nil) {
        let unit = measurementData["unit"] as! String
        let unit2 = measurementData["unit2"] as! String
        let deviceId = measurementData["deviceId"] as! Int
        let measurementValue = measurementData["measurementValue"] as! String
        let measurementType = measurementData["measurementType"] as! String
        
        let valmeasurement = json["details"] as? [String: Any]
        if let value = valmeasurement!["lastValue"] as? Double {
            DispatchQueue.main.async { // Correct
                let (si, newValue) = TableUtil.getSiPrefix(value)
                let value: String = String(format:"%.1f", newValue)
                valueLbl.setText(value)
                waitLbl?.setText("")
                addValueCache(measurementValue: measurementValue, measurementType: measurementType, deviceId: deviceId, value: value)
                unitLbl.setText(si+("" == unit2 ? unit : unit2))
            }
        } else {
            DispatchQueue.main.async { // Correct
                valueLbl.setText("NaN")
                waitLbl?.setText("")
                unitLbl.setText(("" == unit2 ? unit : unit2))
            }
        }
    }
    
    static let defaults = UserDefaults.standard
    
    public static func showOnlineValueInTable(_ json: [String : AnyObject], _ measurementData: [String: Any],_ table: WKInterfaceTable, tableRowIndex index: Int) {
        let deviceId = measurementData["deviceId"] as! Int
        let measurementValue = measurementData["measurementValue"] as! String
        let measurementType = measurementData["measurementType"] as! String
        let unit = measurementData["unit"] as! String
        let unit2 = measurementData["unit2"] as! String
        
        let valmeasurement = json["value"] as? [String: Any]
        if let value = valmeasurement!["\(deviceId).\(measurementValue).\(measurementType)"] as? Double {
            DispatchQueue.main.async { // Correct
                let row = table.rowController(at: index) as? MeasurementRowType
                
                let (si, newValue) = TableUtil.getSiPrefix(value)
                
                if index == 0 {
                    defaults.set("" == unit2 ? unit : unit2, forKey: "UNIT")
                    defaults.set(value, forKey: "VAL")
                }
                
                let value: String = String(format:"%.1f", newValue)
                row?.value.setText(value)
                addValueCache(measurementValue: measurementValue, measurementType: measurementType, deviceId: deviceId, value: value)
                row?.unit.setText(si+("" == unit2 ? unit : unit2))
            }
        } else {
            DispatchQueue.main.async { // Correct
                let row = table.rowController(at: index) as? MeasurementRowType
                row?.value.setText("NaN")
                row?.unit.setText(("" == unit2 ? unit : unit2))
            }
        }
    }
    
    public static func showOnlineValue(_ json: [String : AnyObject], _ measurementData: [String: Any],_ valueLbl: WKInterfaceLabel, _ unitLbl: WKInterfaceLabel, _ waitLbl: WKInterfaceLabel? = nil) {
        let deviceId = measurementData["deviceId"] as! Int
        let measurementValue = measurementData["measurementValue"] as! String
        let measurementType = measurementData["measurementType"] as! String
        let unit = measurementData["unit"] as! String
        let unit2 = measurementData["unit2"] as! String
        
        let valmeasurement = json["value"] as? [String: Any]
        if let value = valmeasurement!["\(deviceId).\(measurementValue).\(measurementType)"] as? Double {
            DispatchQueue.main.async { // Correct
                let (si, newValue) = TableUtil.getSiPrefix(value)
                let value: String = String(format:"%.1f", newValue)
                valueLbl.setText(value)
                waitLbl?.setText("")
                addValueCache(measurementValue: measurementValue, measurementType: measurementType, deviceId: deviceId, value: value)
                unitLbl.setText(si+("" == unit2 ? unit : unit2))
            }
        } else {
            DispatchQueue.main.async { // Correct
                valueLbl.setText("NaN")
                waitLbl?.setText("")
                unitLbl.setText(("" == unit2 ? unit : unit2))
            }
        }
    }
    
    public static func createRequest(_ measurementData:[String: Any], _ serverUrl: String?) -> URLRequest {
        let deviceId = measurementData["deviceId"] as! Int
        let measurementValue = measurementData["measurementValue"] as! String
        let measurementType = measurementData["measurementType"] as! String
        let mode = measurementData["mode"] as! Int
        let timebase = measurementData["timebase"] as! String
        let start = measurementData["start"] as! String
        let end = measurementData["end"] as! String
        
        var requestData = ""
        switch mode {
        case ONLINE:
            requestData = "onlinevalues?value=\(deviceId);\(measurementValue);\(measurementType)"
        case HIST:
            requestData = "devices/\(deviceId)/hist/energy/\(measurementValue)/\(measurementType)?start=\(start)&end=\(end)"
        case MI://
            requestData = "devices/\(deviceId)/manualinput/\(measurementValue)/\(measurementType)/\(timebase)"
        default:
            requestData = "unknown mode"
        }
        
        var request = URLRequest(url: URL(string:"\(serverUrl!)\(requestData)")!)        
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    
    public static func createRequestForChart(_ measurementData:[String: Any], _ serverUrl: String?, namedTime: String) -> URLRequest {
        let deviceId = measurementData["deviceId"] as! Int
        let measurementValue = measurementData["measurementValue"] as! String
        let measurementType = measurementData["measurementType"] as! String
        let timebase = measurementData["timebase"] as! String
        let online = measurementData["isOnline"] as! Bool
        let requestData = "devices/\(deviceId)/hist/values/\(measurementValue)/\(measurementType)/\(timebase)?start=\(namedTime)&end=\(namedTime)&online=\(online)"
        let requestStr = "\(serverUrl!)\(requestData)"
        print(requestStr)
        var request = URLRequest(url: URL(string:requestStr)!)
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}
