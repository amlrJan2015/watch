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
    
    private var dict: [String: Any] = [:]
    private var serverUrl = ""
    private var taskArr:[URLSessionDataTask] = []
    
    fileprivate func fetchAndShowData() {
        DispatchQueue.main.async {
            for index in 0..<self.periodArr.count {
                self.dict["start"] = self.periodArr[index]
                self.dict["stop"] = self.periodArr[index]
                let task = RequestUtil.doGetDataForMainTable(
                    self.serverUrl,
                    self.dict,
                    self.table,
                    atSelectedMeasurementIndex: index)
                task.resume()
                self.taskArr.append(task)
            }
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let tServerUrl_MeasurementDict = context as? (String,[String: Any]) {
            dict = tServerUrl_MeasurementDict.1
            serverUrl = tServerUrl_MeasurementDict.0
            
            self.tableTitle.setText((dict["watchTitle"] as! String))
            table.setNumberOfRows(periodArr.count, withRowType: "histMeasurementRowType")
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        fetchAndShowData()
    }
    
    override func willDisappear() {
        taskArr.forEach { (task) in
            task.cancel()
        }
    }
    
    @IBAction func onInfoClick() {
        var devName = "No info. Please config the value on iPhone again."
        var mInfo = ""
        if let devNameOpt = dict["deviceName"] as? String {
            devName = devNameOpt
            mInfo = "\(dict["measurementValueName"] as! String)\n\(dict["measurementTypeName"] as! String)"
        }
        
        pushController(withName: "MeasurementInfo", context: (devName, mInfo))
    }
    
}
