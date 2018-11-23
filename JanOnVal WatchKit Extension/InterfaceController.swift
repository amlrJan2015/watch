//
//  InterfaceController.swift
//  JanOnVal WatchKit Extension
//
//  Created by Andreas Mueller on 08.12.17.
//  Copyright © 2017 Andreas Mueller. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WKExtensionDelegate, WCSessionDelegate {
    
    let SERVER_CONFIG = "SERVER_CONFIG"
    let MEASUREMENT_DATA = "MEASUREMENT_DATA"
    let REFRESH_TIME = "REFRESH_TIME"
    
    var serverUrl: String?
    var refreshTime: Int?
    
    let defaults = UserDefaults.standard
   
    @IBOutlet var info: WKInterfaceLabel!
    
    var measurementDataDictArr: [[String: Any]]?
    
    @IBOutlet var table: WKInterfaceTable!
    
    var session: WCSession?
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let dict = measurementDataDictArr![rowIndex]
        fetchTimer?.invalidate()
        if TableUtil.HIST == dict["mode"] as! Int {
            pushController(withName: "HistDetail", context: (serverUrl, dict))
        } else {
            pushController(withName: "OnlineMeasurementBig", context: (serverUrl, dict))
        }
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        NSLog("%@", "state: \(activationState) error:\(error)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        measurementDataDictArr = (message["measurementDataDictArr"] as? [[String:Any]])!
        
        table.setNumberOfRows(measurementDataDictArr!.count, withRowType: "measurementRowType")
        
        serverUrl = message["serverUrl"] as? String
        refreshTime = message["refreshTime"] as? Int ?? 5
                
        defaults.set(serverUrl, forKey: SERVER_CONFIG)
        defaults.set(measurementDataDictArr, forKey: MEASUREMENT_DATA)
        defaults.set(refreshTime, forKey: REFRESH_TIME)
        
        table.setNumberOfRows(measurementDataDictArr!.count, withRowType: "measurementRowType")
        getTemp()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        WKExtension.shared().isFrontmostTimeoutExtended = true;
        
        session = WCSession.default
        session?.delegate = self
        session?.activate()
        
        serverUrl = defaults.string(forKey: SERVER_CONFIG)
        measurementDataDictArr = defaults.array(forKey: MEASUREMENT_DATA) as? [[String:Any]]
        refreshTime = defaults.integer(forKey: REFRESH_TIME)
        refreshTime = refreshTime == 0 ? 5 : refreshTime
        
        if serverUrl != nil && measurementDataDictArr != nil {
            
            if table.numberOfRows != measurementDataDictArr?.count{
                table.setNumberOfRows(measurementDataDictArr!.count, withRowType: "measurementRowType")
            }
            
            getTemp()
        } else {
            info.setText("No config")
        }
    }
    
    var fetchTaskArr = Array<URLSessionDataTask>()
    
    var fetchTimer: Timer?
    
    fileprivate func startTimer() {
        DispatchQueue.main.async {
            self.fetchTimer?.invalidate();
            self.fetchTimer = Timer.scheduledTimer(withTimeInterval: Double(self.refreshTime!), repeats: true) { (timer) in
                for index in 0..<self.measurementDataDictArr!.count {
                    if self.fetchTaskArr.count == index || self.fetchTaskArr[index].state == URLSessionTask.State.completed {
                        self.fetchTaskArr.insert(RequestUtil.doGetDataForMainTable(self.serverUrl, self.measurementDataDictArr![index], self.table, atSelectedMeasurementIndex: index), at: index)
                        self.fetchTaskArr[index].resume()
                    }
                }
            }
        }
    }
    
    private func getTemp() {
        self.info.setText("Fetching[\(refreshTime!)s]...")
        if fetchTaskArr.count == 0 {
            //start fetching
            for index in 0..<self.measurementDataDictArr!.count {
                self.fetchTaskArr.append(RequestUtil.doGetDataForMainTable(self.serverUrl, self.measurementDataDictArr![index], self.table, atSelectedMeasurementIndex: index))
                self.fetchTaskArr[index].resume()
            }
        }
        
        startTimer()
    }
    
}
