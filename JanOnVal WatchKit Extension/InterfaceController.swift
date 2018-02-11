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
    
    
    @IBOutlet var info: WKInterfaceLabel!
    
    var selectedMeasurementArr = Array<String>()
    
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
    
    var serverUrl: String?
    let defaults = UserDefaults.standard
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        selectedMeasurementArr = []
        measurementValueArr = []
        let arr = (message["selectedMeasurementArr"] as? [String])
        for item in arr! {
            let splitedStr = item.split(separator: ";")
            selectedMeasurementArr.append("\(String(splitedStr[0]));\(String(splitedStr[1]));\(String(splitedStr[2]))")
            measurementValueArr.append(MeasurementValue(value: nil, unit: String(splitedStr[3])))
        }
        
        table.setNumberOfRows(selectedMeasurementArr.count, withRowType: "measurementRowType")
        
        serverUrl = (message["serverUrl"] as! String)
        NSLog("%@", "server:\(self.serverUrl)")
        //        startFetching.setBackgroundColor(UIColor.init(red: <#T##CGFloat#>, green: <#T##CGFloat#>, blue: <#T##CGFloat#>, alpha: <#T##CGFloat#>))
        
        defaults.set(serverUrl, forKey: SERVER_CONFIG)
        defaults.set(selectedMeasurementArr, forKey: SELECT_MEASUREMENT_ARR)
        defaults.set(measurementValueArr.map({ (measurementValue) -> String in
            return measurementValue.unit ?? ""
        }), forKey: SELECT_MEASUREMENT_VALUE_ARR)
        
        serverUrlOrig = serverUrl!
        selectedMeasurementArrOrig = selectedMeasurementArr
        
        getTemp()
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    let SERVER_CONFIG = "SERVER_CONFIG"
    let SELECT_MEASUREMENT_ARR = "SELECT_MEASUREMENT_ARR"
    let SELECT_MEASUREMENT_VALUE_ARR = "SELECT_MEASUREMENT_VALUE_ARR"
    
    var serverUrlOrig = ""
    var selectedMeasurementArrOrig = [String]()
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        session = WCSession.default
        session?.delegate = self
        session?.activate()
        
        serverUrl = defaults.string(forKey: SERVER_CONFIG)
        if serverUrl != nil {
            selectedMeasurementArr = defaults.array(forKey: SELECT_MEASUREMENT_ARR) as! [String]
            measurementValueArr = (defaults.array(forKey: SELECT_MEASUREMENT_VALUE_ARR) as! [String]).map({ (unit) -> MeasurementValue in
                return MeasurementValue(value: nil, unit: unit)
            })
            
            if serverUrlOrig != serverUrl && selectedMeasurementArrOrig != selectedMeasurementArr {
                table.setNumberOfRows(selectedMeasurementArr.count, withRowType: "measurementRowType")
                serverUrlOrig = serverUrl!
                selectedMeasurementArrOrig = selectedMeasurementArr
                getTemp()
            }
        } else {
            info.setText("No config")
        }
    }
    
    var measurementValueArr = Array<MeasurementValue>()
    
    private func configureTableWithData() {
        table.setNumberOfRows(selectedMeasurementArr.count, withRowType: "measurementRowType")
        
        for index in 0..<selectedMeasurementArr.count {
            let row = table.rowController(at: index) as? MeasurementRowType
            let measurement = selectedMeasurementArr[index]
            
            row?.value.setText("\(measurementValueArr[index].value)")
            row?.unit.setText(String(measurement.split(separator: ";")[3]))
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    var fetchTaskArr = Array<URLSessionDataTask>()
    
    
    private func doGetData(atSelectedMeasurementIndex index: Int) -> URLSessionDataTask {
        //        print("RequestTo:\(self.serverUrl!)onlinevalues?value=\(self.selectedMeasurementArr[index])")
        var request = URLRequest(url: URL(string:"\(self.serverUrl!)onlinevalues?value=\(self.selectedMeasurementArr[index])")!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let session = URLSession.shared
        return session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                DispatchQueue.main.async { // Correct
                    let measurementStr = self.selectedMeasurementArr[index]
                    let measurementStrSplited = measurementStr.split(separator: ";")
                    let deviceId = String(measurementStrSplited[0])
                    let value = String(measurementStrSplited[1])
                    let type = String(measurementStrSplited[2])
                    let unit = self.measurementValueArr[index].unit
                    
                    guard let measurementValue = json["value"] as? [String: Any],
                        let t = measurementValue["\(deviceId).\(value).\(type)"] as? Double else {
                            return
                    }
                    //                    print("T:\(t)")
                    //                    self.temperatureLbl.setText(String(format:"W[T]:%.1f˚", t))
                    self.measurementValueArr[index] = MeasurementValue(value: t, unit: unit)
                    
                    let row = self.table.rowController(at: index) as? MeasurementRowType
                    
                    row?.value.setText(String(format:"%.1f", t))
                    row?.unit.setText(unit)
                }
            } catch {
                print("error:\(error)")
            }
            
        })
    }
    
    var fetchTimer: Timer?;
    
    private func getTemp() {
        info.setText("Fetching[2s]...")
        fetchTimer?.invalidate();
        
        fetchTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (timer) in
            for index in 0..<self.selectedMeasurementArr.count {
                if self.fetchTaskArr.count == index || self.fetchTaskArr[index].state == URLSessionTask.State.completed {
                    self.fetchTaskArr.insert(self.doGetData(atSelectedMeasurementIndex: index), at: index)
                    self.fetchTaskArr[index].resume()
                }
            }
        }
        if fetchTimer!.isValid {
            fetchTimer!.fire()
        }
    }
}
