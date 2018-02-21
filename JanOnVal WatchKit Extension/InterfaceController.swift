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
        let dict = measurementDataDictArr![rowIndex]
        if TableUtil.HIST == dict["mode"] as! Int {
            presentController(withName: "HistDetail", context: (serverUrl, dict))
        }
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
    
    
    
    var fetchTimer: Timer?;
    
    private func getTemp() {
        DispatchQueue.main.async {
            self.info.setText("Fetching[2s]...")
            self.fetchTimer?.invalidate();
            self.fetchTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (timer) in
                for index in 0..<self.measurementDataDictArr!.count {
                    if self.fetchTaskArr.count == index || self.fetchTaskArr[index].state == URLSessionTask.State.completed {
                        self.fetchTaskArr.insert(RequestUtil.doGetData(self.serverUrl, self.measurementDataDictArr![index], self.table, atSelectedMeasurementIndex: index), at: index)
                        self.fetchTaskArr[index].resume()
                    }
                }
            }
        }
    }
}
