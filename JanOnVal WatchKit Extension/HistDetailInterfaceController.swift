//
//  HistDetailInterfaceController.swift
//  JanOnVal WatchKit Extension
//
//  Created by Andreas Müller on 20.02.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import WatchKit
import Foundation


class HistDetailInterfaceController: WKInterfaceController {
    
    @IBOutlet var table: WKInterfaceTable!
    @IBOutlet var tableTitle: WKInterfaceLabel!
    
    let periodArr = ["NAMED_Today", "NAMED_Yesterday", "NAMED_ThisWeek", "NAMED_LastWeek", "NAMED_ThisMonth", "NAMED_LastMonth", "NAMED_ThisYear", "NAMED_LastYear"]
    var fetchTaskArr = Array<URLSessionDataTask>()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let tServerUrl_MeasurementDict = context as? (String,[String: Any]) {
            self.tableTitle.setText(tServerUrl_MeasurementDict.1["watchTitle"] as! String)
            table.setNumberOfRows(periodArr.count, withRowType: "histMeasurementRowType")
            
            var histDict = tServerUrl_MeasurementDict.1            
            
            DispatchQueue.main.async {
                for index in 0..<self.periodArr.count {
                    histDict["start"] = self.periodArr[index]
                    histDict["stop"] = self.periodArr[index]
                    let task = RequestUtil.doGetDataForMainTable(
                        tServerUrl_MeasurementDict.0,
                        histDict,
                        self.table,
                        atSelectedMeasurementIndex: index)
                    task.resume()
                }
            }
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
