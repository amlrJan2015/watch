//
//  RequestUtil.swift
//  JanOnVal WatchKit Extension
//
//  Created by Andreas Müller on 21.02.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import Foundation
import WatchKit

class RequestUtil {
    public static func doGetDataForMainTable(_ serverUrl: String?, _ measurementData:[String:Any],_ table: WKInterfaceTable, atSelectedMeasurementIndex index: Int) -> URLSessionDataTask {
        //        print("RequestTo:\(self.serverUrl!)onlinevalues?value=\(self.selectedMeasurementArr[index])")
        let mode = measurementData["mode"] as! Int
        let request = TableUtil.createRequest(measurementData, serverUrl)
        let session = URLSession.shared
        
        return session.dataTask(with: request) { data, response, error -> Void in
            
            do {
                if let measurementDataJson = data {
                    //                    print(String(data: measurementData,encoding: String.Encoding.utf8) as! String)
                    let json = try JSONSerialization.jsonObject(with: measurementDataJson) as! Dictionary<String, AnyObject>
                    
                    switch mode {
                    case TableUtil.ONLINE:
                        TableUtil.showOnlineValueInTable(json, measurementData, table, tableRowIndex: index)
                    case TableUtil.HIST:
                        TableUtil.showHistEnergyValueInTable(json, measurementData, table, tableRowIndex: index)
                    case TableUtil.MI:
                        TableUtil.showManualInputInTable(json, measurementData, table, tableRowIndex: index)
                    default:
                        print("unknown mode")
                    }
                } else {
                    DispatchQueue.main.async { // Correct
                        let row = table.rowController(at: index) as? MeasurementRowType
                        row?.value.setText("⏳")
                        row?.unit.setText("")
                    }
                }
            } catch {
                //                print("error:\(error)")
                DispatchQueue.main.async { // Correct
                    if let row = table.rowController(at: index) as? HistMeasurementRowType {
                        row.dateDesc.setText("🚫")
                        row.value.setWidth(95.0)
                        row.value.setText("no values")
                        row.unit.setText("")
                    } else if let row = table.rowController(at: index) as? MeasurementRowType {
                        row.header.setText("🚫")
                        row.value.sizeToFitWidth()
                        row.value.setText("no values")
                        row.unit.setText("")
                    }
                    
                    
                }
            }
            
        }
    }
    
    private static func getFormattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.string(from: Date())
    }
    
    public static func doGetCloudDataForMainTable(_ firestoreData: [String:String], _ cloudToken: String, _ table: WKInterfaceTable, atSelectedMeasurementIndex index: Int, _ interfaceController: WKInterfaceController) -> URLSessionDataTask {
        
        let request = TableUtil.createFirestoreRequest(firestoreData, cloudToken)
        let session = URLSession.shared
        
        return session.dataTask(with: request) { data, response, error -> Void in
            do {
                if let response = response as? HTTPURLResponse {
                    let statusCode = response.statusCode
                    
                    if statusCode == 200 {
                        if let measurementDataJson = data {
                            //                    print(String(data: measurementData,encoding: String.Encoding.utf8) as! String)
                            let json = try JSONSerialization.jsonObject(with: measurementDataJson) as! Dictionary<String, AnyObject>
                            let fields = json["fields"] as! [String: Any]
                            let energy = fields["energy"] as! [String: Any]
                            let energyMapValues = energy["mapValue"] as! [String: Any]
                            let energyMapValuesFields = energyMapValues["fields"] as! [String: Any]
                            let eNow = energyMapValuesFields[getFormattedDate()] as! [String: Any]
                            var eNowValue = "error"
                            if let intValue = eNow["integerValue"] {
                                eNowValue = intValue as! String
                            }
                            if let doubleValue = eNow["doubleValue"] {
                                eNowValue = doubleValue as! String
                            }                            
                            
                            if let valueAsDouble = Double(eNowValue) {
                                let (si, newValue) = TableUtil.getSiPrefix(valueAsDouble)
                                DispatchQueue.main.async { // Correct
                                    let row = table.rowController(at: index) as? MeasurementRowType
                                    row?.value.setText(String(format:"%.1f", newValue))
                                    row?.unit.setText("\(si)Wh")
                                }
                            } else {
                                DispatchQueue.main.async { // Correct
                                    let row = table.rowController(at: index) as? MeasurementRowType
                                    row?.value.setText(eNowValue)
                                    row?.unit.setText("Wh")
                                }
                            }
                        }
                    } else if statusCode == 403 || statusCode == 401 {
                        print("doGetCloudDataForMainTable: let refresh token:\(statusCode)")
                        let action = WKAlertAction(title: "on iPhone",style: WKAlertActionStyle.destructive){}
                        interfaceController.presentAlert(withTitle: "CloudToken", message: "Please refresh Cloud Token!", preferredStyle: WKAlertControllerStyle.alert, actions: [action])
                    }
                } else {
                    print("doGetCloudDataForMainTable: response is nil")
                }
            } catch {
                //                print("error:\(error)")
                DispatchQueue.main.async { // Correct
                    if let row = table.rowController(at: index) as? MeasurementRowType {
                        row.header.setText("🚫")
                        row.value.sizeToFitWidth()
                        row.value.setText("no values")
                        row.unit.setText("")
                    }
                }
            }
            
        }
    }    
    
    
    public static func doGetRealtimeDBDataForMainTable(_ firestoreData: [String:String], _ cloudToken: String, _ table: WKInterfaceTable, atSelectedMeasurementIndex index: Int, _ interfaceController: WKInterfaceController) -> URLSessionDataTask {
        
        let request = TableUtil.createRTDBRequest(firestoreData, cloudToken)
        let session = URLSession.shared
        
        return session.dataTask(with: request) { data, response, error -> Void in
            do {
                if let response = response as? HTTPURLResponse {
                    let statusCode = response.statusCode
                    
                    if statusCode == 200 {
                        if let measurementDataJson = data {
                            //                    print(String(data: measurementData,encoding: String.Encoding.utf8) as! String)
                            let json = try JSONSerialization.jsonObject(with: measurementDataJson) as! Dictionary<String, AnyObject>
                            //                            let keys = json.keys
                            //                            for key in keys {
                            //                                if let consumerData = json[key] as? [String:Any] {
                            if let value = json["value"] as? Double,
                                let unit = json["unit"] as? String {
                                let (si, newValue) = TableUtil.getSiPrefix(value)
                                DispatchQueue.main.async { // Correct
                                    let row = table.rowController(at: index) as? MeasurementRowType
                                    row?.value.setText(String(format:"%.1f", newValue))
                                    row?.unit.setText("\(si)\(unit)")
                                }
                            } else {
                                DispatchQueue.main.async { // Correct
                                    let row = table.rowController(at: index) as? MeasurementRowType
                                    row?.value.setText("not double")
                                    row?.unit.setText("?")
                                }
                                
                            }
                            //                                }
                            //                            }
                        }
                    } else if statusCode == 403 || statusCode == 401 {
                        print("doGetRealtimeDBDataForMainTable: let refresh token:\(statusCode)")
                        let action = WKAlertAction(title: "on iPhone",style: WKAlertActionStyle.destructive){}
                        interfaceController.presentAlert(withTitle: "CloudToken", message: "Please refresh Cloud Token!", preferredStyle: WKAlertControllerStyle.alert, actions: [action])
                    }
                } else {
                    print("doGetRealtimeDBDataForMainTable: response is nil")
                }
            } catch {
                //                print("error:\(error)")
                DispatchQueue.main.async { // Correct
                    if let row = table.rowController(at: index) as? MeasurementRowType {
                        row.header.setText("🚫")
                        row.value.sizeToFitWidth()
                        row.value.setText("no values")
                        row.unit.setText("")
                    }
                }
            }
            
        }
    }
    
    
    public static func doGetData(_ serverUrl: String?, _ measurementData:[String:Any], _ valueLbl: WKInterfaceLabel, _ unitLbl: WKInterfaceLabel, _ waitLbl: WKInterfaceLabel? = nil) -> URLSessionDataTask {
        //        print("RequestTo:\(self.serverUrl!)onlinevalues?value=\(self.selectedMeasurementArr[index])")
        let mode = measurementData["mode"] as! Int
        let request = TableUtil.createRequest(measurementData, serverUrl)
        let session = URLSession.shared
        
        return session.dataTask(with: request) { data, response, error -> Void in
            
            do {
                OnlineMeasurementBig.updateStateCounter = 0
                if let measurementDataJson = data {
                    //                    print(String(data: measurementData,encoding: String.Encoding.utf8) as! String)
                    let json = try JSONSerialization.jsonObject(with: measurementDataJson) as! Dictionary<String, AnyObject>
                    
                    switch mode {
                    case TableUtil.ONLINE:
                        TableUtil.showOnlineValue(json, measurementData, valueLbl, unitLbl, waitLbl)
                    case TableUtil.HIST:
                        TableUtil.showHistEnergyValue(json, measurementData, valueLbl, unitLbl, waitLbl)
                    case TableUtil.MI:
                        TableUtil.showManualInput(json, measurementData, valueLbl, unitLbl, waitLbl)
                    default:
                        print("unknown mode")
                    }
                } else {
                    DispatchQueue.main.async { // Correct
                        valueLbl.setText("🚫")
                        unitLbl.setText("")
                        waitLbl?.setText("")
                    }
                }
            } catch {
                DispatchQueue.main.async { // Correct
                    valueLbl.setText("🚫")
                    unitLbl.setText("")
                    waitLbl?.setText("")
                }
            }
            
        }
    }
}
