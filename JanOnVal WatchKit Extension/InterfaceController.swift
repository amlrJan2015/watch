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
    
    private func logC(val: Double, forBase base: Double) -> Double {
        return log(val)/log(base)
    }

    
    private func getSiPrefix(_ value: Double) -> (String, Double) {
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
    
    var fetchTaskArr = Array<URLSessionDataTask>()
    
    
    private func showOnlineValueInTable(_ json: [String : AnyObject], _ measurementData: [String: Any], tableRowIndex index: Int) {
        let deviceId = measurementData["deviceId"] as! Int
        let measurementValue = measurementData["measurementValue"] as! String
        let measurementType = measurementData["measurementType"] as! String
        let unit = measurementData["unit"] as! String
        let title = measurementData["watchTitle"] as! String
        
        let valmeasurement = json["value"] as? [String: Any]
        if let value = valmeasurement!["\(deviceId).\(measurementValue).\(measurementType)"] as? Double {
            DispatchQueue.main.async { // Correct
                let row = self.table.rowController(at: index) as? MeasurementRowType
                
                let (si, newValue) = self.getSiPrefix(value)
                
                row?.value.setText(String(format:"%.1f", newValue))
                row?.unit.setText(si+unit)
                row?.header.setText(title)
            }
        } else {
            DispatchQueue.main.async { // Correct
                let row = self.table.rowController(at: index) as? MeasurementRowType
                row?.value.setText("NaN")
                row?.unit.setText(unit)
                row?.header.setText(title)
            }
        }
    }
    
    private func showHistEnergyValueInTable(_ json: [String : AnyObject], _ measurementData: [String: Any], tableRowIndex index: Int) {
        let unit = measurementData["unit"] as! String
        let title = measurementData["watchTitle"] as! String
        
        if let value = json["energy"] as? Double {
            DispatchQueue.main.async { // Correct
                let row = self.table.rowController(at: index) as? MeasurementRowType
                
                let (si, newValue) = self.getSiPrefix(value)
                
                row?.value.setText(String(format:"%.1f", newValue))
                row?.unit.setText(si+unit)
                row?.header.setText(title)
            }
        } else {
            DispatchQueue.main.async { // Correct
                let row = self.table.rowController(at: index) as? MeasurementRowType
                row?.value.setText("NaN")
                row?.unit.setText(unit)
                row?.header.setText(title)
            }
        }
    }
    
    private func doGetData(atSelectedMeasurementIndex index: Int) -> URLSessionDataTask {
        //        print("RequestTo:\(self.serverUrl!)onlinevalues?value=\(self.selectedMeasurementArr[index])")
        let measurementData = self.measurementDataDictArr![index]
        let deviceId = measurementData["deviceId"] as! Int
        let measurementValue = measurementData["measurementValue"] as! String
        let measurementType = measurementData["measurementType"] as! String
        let isOnline = measurementData["isOnline"] as! Bool
        let start = measurementData["start"] as! String
        let end = measurementData["end"] as! String
        
        var requestData = ""
        if isOnline {
            requestData = "onlinevalues?value=\(deviceId);\(measurementValue);\(measurementType)"
        } else {
//            hist/energy/ActiveEnergyConsumed/SUM13?start=NAMED_Today&end=NAMED_Today
            requestData = "devices/\(deviceId)/hist/energy/\(measurementValue)/\(measurementType)?start=\(start)&end=\(end)"
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
                    
                    if isOnline {
                        self.showOnlineValueInTable(json, measurementData, tableRowIndex: index)
                    } else {
                        self.showHistEnergyValueInTable(json, measurementData, tableRowIndex: index)
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
        info.setText("Fetching[2s]...")
//        fetchTimer?.invalidate();
        
        fetchTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (timer) in
            for index in 0..<self.measurementDataDictArr!.count {
                if self.fetchTaskArr.count == index || self.fetchTaskArr[index].state == URLSessionTask.State.completed {
                    print("start task")
                    self.fetchTaskArr.insert(self.doGetData(atSelectedMeasurementIndex: index), at: index)
                    self.fetchTaskArr[index].resume()
                }
                print("task must be run")
            }
        }
//        if fetchTimer!.isValid {
//            fetchTimer!.fire()
//        }
    }
}
