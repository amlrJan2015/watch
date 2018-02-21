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
    public static func doGetData(_ serverUrl: String?, _ measurementData:[String:Any],_ table: WKInterfaceTable, atSelectedMeasurementIndex index: Int) -> URLSessionDataTask {
        //        print("RequestTo:\(self.serverUrl!)onlinevalues?value=\(self.selectedMeasurementArr[index])")
        let mode = measurementData["mode"] as! Int
        let request = TableUtil.createRequest(measurementData, serverUrl)
        let session = URLSession.shared
        
        return session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            
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
                        row?.value.setText("--")
                        row?.unit.setText("")
                    }
                }
            } catch {
                print("error:\(error)")
            }
            
        })
    }
}
