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
    
    private static func logC(val: Double, forBase base: Double) -> Double {
        return log(val)/log(base)
    }    
    
    public static func getSiPrefix(_ value: Double) -> (String, Double) {
        var result = ("",value)
        
        let pow10 = logC(val: abs(value), forBase: 10.0)

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
                let (si, newValue) = getSiPrefix(value)
                if let row = table.rowController(at: index) as? MeasurementRowType {
                    row.value.setText(String(format:"%.1f", newValue))
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
        let title = measurementData["watchTitle"] as! String
        
        let valmeasurement = json["details"] as? [String: Any]
        if let value = valmeasurement!["lastValue"] as? Double {
            DispatchQueue.main.async { // Correct
                let row = table.rowController(at: index) as? MeasurementRowType
                
                let (si, newValue) = TableUtil.getSiPrefix(value)
                
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
    
    public static func showManualInput(_ json: [String : AnyObject], _ measurementData: [String: Any],_ valueLbl: WKInterfaceLabel, _ unitLbl: WKInterfaceLabel) {
        let unit = measurementData["unit"] as! String
        let unit2 = measurementData["unit2"] as! String
        
        let valmeasurement = json["details"] as? [String: Any]
        if let value = valmeasurement!["lastValue"] as? Double {
            DispatchQueue.main.async { // Correct
                let (si, newValue) = TableUtil.getSiPrefix(value)
                
                valueLbl.setText(String(format:"%.1f", newValue))
                unitLbl.setText(si+("" == unit2 ? unit : unit2))
            }
        } else {
            DispatchQueue.main.async { // Correct
                valueLbl.setText("NaN")
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
        let title = measurementData["watchTitle"] as! String
        
        let valmeasurement = json["value"] as? [String: Any]
        if let value = valmeasurement!["\(deviceId).\(measurementValue).\(measurementType)"] as? Double {
            DispatchQueue.main.async { // Correct
                let row = table.rowController(at: index) as? MeasurementRowType
                
                let (si, newValue) = TableUtil.getSiPrefix(value)
                
                if index == 0 {
                    defaults.set("" == unit2 ? unit : unit2, forKey: "UNIT")
                    defaults.set(value, forKey: "VAL")
                }
                
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
    
    public static func showOnlineValue(_ json: [String : AnyObject], _ measurementData: [String: Any],_ valueLbl: WKInterfaceLabel, _ unitLbl: WKInterfaceLabel) {
        let deviceId = measurementData["deviceId"] as! Int
        let measurementValue = measurementData["measurementValue"] as! String
        let measurementType = measurementData["measurementType"] as! String
        let unit = measurementData["unit"] as! String
        let unit2 = measurementData["unit2"] as! String
        
        let valmeasurement = json["value"] as? [String: Any]
        if let value = valmeasurement!["\(deviceId).\(measurementValue).\(measurementType)"] as? Double {
            DispatchQueue.main.async { // Correct
                let (si, newValue) = TableUtil.getSiPrefix(value)
                valueLbl.setText(String(format:"%.1f", newValue))
                unitLbl.setText(si+("" == unit2 ? unit : unit2))
            }
        } else {
            DispatchQueue.main.async { // Correct
                valueLbl.setText("NaN")
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
//        let mode = measurementData["mode"] as! Int
        let timebase = measurementData["timebase"] as! String
//        let start = "NAMED_Yesterday"//measurementData["start"] as! String
//        let end = "NAMED_Yesterday"//measurementData["end"] as! String
        let online = measurementData["isOnline"] as! Bool
        //devices/7/hist/values/PowerActive/SUM13/60/?start=NAMED_Today&end=NAMED_Today&online=true
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
