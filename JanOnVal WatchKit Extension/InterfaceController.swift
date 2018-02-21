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
    
    var serverUrl: String?
    let defaults = UserDefaults.standard
    
    //    var serverUrlOrig = ""
    //    var measurementDataDictArrOrig = [[String:Any]]()
    
    @IBOutlet var info: WKInterfaceLabel!
    
    var measurementDataDictArr: [[String: Any]]?
    
    @IBOutlet var table: WKInterfaceTable!
    
    var session: WCSession?
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        presentController(withName: "HistDetail", context: measurementDataDictArr![rowIndex])
    }
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
    }
    
    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        NSLog("%@", "state: \(activationState) error:\(error)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        measurementDataDictArr = (message["measurementDataDictArr"] as? [[String:Any]])!
        
        table.setNumberOfRows(measurementDataDictArr!.count, withRowType: "measurementRowType")
        
        serverUrl = (message["serverUrl"] as! String)
        
        //        startFetching.setBackgroundColor(UIColor.init(red: <#T##CGFloat#>, green: <#T##CGFloat#>, blue: <#T##CGFloat#>, alpha: <#T##CGFloat#>))
        
        defaults.set(serverUrl, forKey: SERVER_CONFIG)
        defaults.set(measurementDataDictArr, forKey: MEASUREMENT_DATA)
        
        table.setNumberOfRows(measurementDataDictArr!.count, withRowType: "measurementRowType")
        getTemp()
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        session = WCSession.default
        session?.delegate = self
        session?.activate()
        
        serverUrl = defaults.string(forKey: SERVER_CONFIG)
        measurementDataDictArr = defaults.array(forKey: MEASUREMENT_DATA) as? [[String:Any]]
        if serverUrl != nil && measurementDataDictArr != nil {
            
            if table.numberOfRows != measurementDataDictArr?.count{
                table.setNumberOfRows(measurementDataDictArr!.count, withRowType: "measurementRowType")
            }
            
            getTemp()
        } else {
            info.setText("No config")
        }
    }
    
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    
    
    
    var fetchTaskArr = Array<URLSessionDataTask>()
    
    private func showManualInputInTable(_ json: [String : AnyObject], _ measurementData: [String: Any], tableRowIndex index: Int) {
        let unit = measurementData["unit"] as! String
        let unit2 = measurementData["unit2"] as! String
        let title = measurementData["watchTitle"] as! String
        
        let valmeasurement = json["details"] as? [String: Any]
        if let value = valmeasurement!["lastValue"] as? Double {
            DispatchQueue.main.async { // Correct
                let row = self.table.rowController(at: index) as? MeasurementRowType
                
                let (si, newValue) = TableUtil.getSiPrefix(value)
                
                row?.value.setText(String(format:"%.1f", newValue))
                row?.unit.setText(si+("" == unit2 ? unit : unit2))
                row?.header.setText(title)
            }
        } else {
            DispatchQueue.main.async { // Correct
                let row = self.table.rowController(at: index) as? MeasurementRowType
                row?.value.setText("NaN")
                row?.unit.setText(("" == unit2 ? unit : unit2))
                row?.header.setText(title)
            }
        }
    }
    
    private func showOnlineValueInTable(_ json: [String : AnyObject], _ measurementData: [String: Any], tableRowIndex index: Int) {
        let deviceId = measurementData["deviceId"] as! Int
        let measurementValue = measurementData["measurementValue"] as! String
        let measurementType = measurementData["measurementType"] as! String
        let unit = measurementData["unit"] as! String
        let unit2 = measurementData["unit2"] as! String
        let title = measurementData["watchTitle"] as! String
        
        let valmeasurement = json["value"] as? [String: Any]
        if let value = valmeasurement!["\(deviceId).\(measurementValue).\(measurementType)"] as? Double {
            DispatchQueue.main.async { // Correct
                let row = self.table.rowController(at: index) as? MeasurementRowType
                
                let (si, newValue) = TableUtil.getSiPrefix(value)
                
                row?.value.setText(String(format:"%.1f", newValue))
                row?.unit.setText(si+("" == unit2 ? unit : unit2))
                row?.header.setText(title)
            }
        } else {
            DispatchQueue.main.async { // Correct
                let row = self.table.rowController(at: index) as? MeasurementRowType
                row?.value.setText("NaN")
                row?.unit.setText(("" == unit2 ? unit : unit2))
                row?.header.setText(title)
            }
        }
    }
    
    
    
    private let ONLINE = 0, HIST = 1, MI = 2
    
    private func doGetData(atSelectedMeasurementIndex index: Int) -> URLSessionDataTask {
        //        print("RequestTo:\(self.serverUrl!)onlinevalues?value=\(self.selectedMeasurementArr[index])")
        let measurementData = self.measurementDataDictArr![index]
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
        
        var request = URLRequest(url: URL(string:"\(self.serverUrl!)\(requestData)")!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let session = URLSession.shared
        return session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            
            do {
                if let measurementDataJson = data {
                    //                    print(String(data: measurementData,encoding: String.Encoding.utf8) as! String)
                    let json = try JSONSerialization.jsonObject(with: measurementDataJson) as! Dictionary<String, AnyObject>
                    
                    switch mode {
                    case self.ONLINE:
                        self.showOnlineValueInTable(json, measurementData, tableRowIndex: index)
                    case self.HIST:
                        TableUtil.showHistEnergyValueInTable(json, measurementData, self.table, tableRowIndex: index)
                    case self.MI:
                        self.showManualInputInTable(json, measurementData, tableRowIndex: index)
                    default:
                        print("unknown mode")
                    }
                } else {
                    DispatchQueue.main.async { // Correct
                        let row = self.table.rowController(at: index) as? MeasurementRowType
                        row?.value.setText("--")
                        row?.unit.setText("")
                    }
                }
            } catch {
                print("error:\(error)")
            }
            
        })
    }
    
    var fetchTimer: Timer?;
    
    private func getTemp() {
        DispatchQueue.main.async {
            self.info.setText("Fetching[2s]...")
            self.fetchTimer?.invalidate();
            self.fetchTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (timer) in
                for index in 0..<self.measurementDataDictArr!.count {
                    if self.fetchTaskArr.count == index || self.fetchTaskArr[index].state == URLSessionTask.State.completed {
                        self.fetchTaskArr.insert(self.doGetData(atSelectedMeasurementIndex: index), at: index)
                        self.fetchTaskArr[index].resume()
                    }
                }
            }
        }
    }
}
