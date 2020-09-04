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
    
    public static let SERVER_CONFIG = "SERVER_CONFIG"
    public static let MEASUREMENT_DATA = "MEASUREMENT_DATA"
    public static let REFRESH_TIME = "REFRESH_TIME"
    
    public static let CLOUD_TOKEN = "CLOUD_TOKEN"
    public static let FIRESTORE_DATA = "FIRESTORE_DATA"
    
    
    public static let MODE = "MODE"
    public static let CLOUD_MODE = "CLOUD_MODE"
    public static let REST_MODE = "REST_MODE"
    
    let defaults = UserDefaults.standard
    
    @IBOutlet var info: WKInterfaceLabel!
    
    
    @IBOutlet var table: WKInterfaceTable!
    
    var session: WCSession?
    
    func didReceiveRemoteNotification(_ userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (WKBackgroundFetchResult) -> Void) {
        print("REMOTE NOTIFICATION")
    }
    
    override func awake(withContext context: Any?) {
        if defaults.object(forKey: OptionsInterfaceController.SHOW_6_12_18) == nil {
            defaults.set(OptionsInterfaceController.SHOW_6_12_18_defaultValue, forKey: OptionsInterfaceController.SHOW_6_12_18)
        }
        if defaults.object(forKey: OptionsInterfaceController.SHOW_Values_On_Y_Axis) == nil {
            defaults.set(OptionsInterfaceController.SHOW_Values_On_Y_Axis_defaultValue, forKey: OptionsInterfaceController.SHOW_Values_On_Y_Axis)
        }
        if defaults.object(forKey: OptionsInterfaceController.SHOW_DERIVATIVE_CHART) == nil {
            defaults.set(OptionsInterfaceController.SHOW_DERIVATIVE_CHART_defaultValue, forKey: OptionsInterfaceController.SHOW_DERIVATIVE_CHART)
        }
        if defaults.object(forKey: OptionsInterfaceController.SHOW_YESTERDAY_AND_TODAY_TOGETHER) == nil {
            defaults.set(OptionsInterfaceController.SHOW_YESTERDAY_AND_TODAY_TOGETHER_defaultValue, forKey: OptionsInterfaceController.SHOW_YESTERDAY_AND_TODAY_TOGETHER)
        }
        
        if defaults.object(forKey: InterfaceController.MODE) == nil {
            defaults.set(InterfaceController.REST_MODE, forKey: InterfaceController.MODE)
        }
        
        WKExtension.shared().registerForRemoteNotifications()
    }
    
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        print("REGISTER OK")
    }
    func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
        print("REGISTER FAILED!!!!")
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if InterfaceController.isRestMode() {
            if let measurementDataDictArr = defaults.array(forKey: InterfaceController.MEASUREMENT_DATA) as? [[String:Any]],
                let serverUrl = defaults.string(forKey: InterfaceController.SERVER_CONFIG) {
                let dict = measurementDataDictArr[rowIndex]
                fetchTimer?.invalidate()
                if TableUtil.HIST == dict["mode"] as! Int {
                    pushController(withName: "HistDetail", context: (serverUrl, dict))
                } else {
                    pushController(withName: "OnlineMeasurementBig", context: (serverUrl, dict))
                }
            } else {
                info.setText("No config")
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        NSLog("%@", "state: \(activationState.rawValue) error:\(String(describing: error))")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        let measurementDataDictArr = (message["measurementDataDictArr"] as? [[String:Any]])!
        
        //        table.setNumberOfRows(measurementDataDictArr!.count, withRowType: "measurementRowType")
        
        let serverUrl = message["serverUrl"] as? String
        let refreshTime = message["refreshTime"] as? Int ?? 5
        
        defaults.set(serverUrl, forKey: InterfaceController.SERVER_CONFIG)
        defaults.set(measurementDataDictArr, forKey: InterfaceController.MEASUREMENT_DATA)
        defaults.set(refreshTime, forKey: InterfaceController.REFRESH_TIME)
        
        table.setNumberOfRows(measurementDataDictArr.count, withRowType: "measurementRowType")
        getTemp()
    }
    
    fileprivate func initShowData(_ count: Int) {
        table.setNumberOfRows(count, withRowType: "measurementRowType")
        getTemp()
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            if let value = userInfo["VALUE"] as? [String:String] {
                UserDefaults.standard.set(value, forKey: "VALUE")
                let server = CLKComplicationServer.sharedInstance()
                guard let complications = server.activeComplications else {return}
                for complication in complications {
                    server.reloadTimeline(for: complication)
                }
            }
        }
        
        
        if let measurementDataDictArrGranted = userInfo["measurementDataDictArr"] as? [[String:Any]] {
            let serverUrl = userInfo["serverUrl"] as? String
            let refreshTime = userInfo["refreshTime"] as? Int ?? 5
            
            defaults.set(serverUrl, forKey: InterfaceController.SERVER_CONFIG)
            defaults.set(measurementDataDictArrGranted, forKey: InterfaceController.MEASUREMENT_DATA)
            defaults.set(refreshTime, forKey: InterfaceController.REFRESH_TIME)
            
            initShowData(measurementDataDictArrGranted.count)
        }
        
        if let cloudToken = userInfo["cloudToken"] as? String,
            let firestoreData = userInfo["firestoreData"] as? [[String:String]] {
            print("CloudToken on Watch", cloudToken)
            print("firestoreData on Watch", firestoreData.count)
            defaults.set(cloudToken, forKey: InterfaceController.CLOUD_TOKEN)
            defaults.set(firestoreData, forKey: InterfaceController.FIRESTORE_DATA)
            
            initShowData(firestoreData.count)
        }
    }
    
    public static func isCloudMode() -> Bool {
        let ud = UserDefaults.standard
        return ud.object(forKey: InterfaceController.MODE) as! String == InterfaceController.CLOUD_MODE
    }
    
    public static func isRestMode() -> Bool {
        let ud = UserDefaults.standard
        return ud.object(forKey: InterfaceController.MODE) as! String == InterfaceController.REST_MODE
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        WKExtension.shared().isFrontmostTimeoutExtended = true;
        
        session = WCSession.default
        session?.delegate = self
        if session?.activationState != WCSessionActivationState.activated {
            session?.activate()
        }
        
        if InterfaceController.isRestMode() {
            let serverUrl = defaults.string(forKey: InterfaceController.SERVER_CONFIG)
            let measurementDataDictArr = defaults.array(forKey: InterfaceController.MEASUREMENT_DATA) as? [[String:Any]]
            var refreshTime = defaults.integer(forKey: InterfaceController.REFRESH_TIME)
            refreshTime = refreshTime == 0 ? 5 : refreshTime
            
            if serverUrl != nil && measurementDataDictArr != nil {
                
                if table.numberOfRows != measurementDataDictArr?.count{
                    table.setNumberOfRows(measurementDataDictArr!.count, withRowType: "measurementRowType")
                }
                
                getTemp()
            } else {
                info.setText("No config")
            }
        } else if InterfaceController.isCloudMode() {
            if let firestoreData = defaults.object(forKey: InterfaceController.FIRESTORE_DATA) as? [[String:String]] {
                //                info.setText("Cloud devices: \(firestoreData.count)")
                if table.numberOfRows != firestoreData.count {
                    table.setNumberOfRows(firestoreData.count, withRowType: "measurementRowType")
                }
                
                getTemp()
            } else {
                info.setText("No Cloud Data")
            }
            
        } else {
            info.setText("Mode is unknown")
        }
    }
    
    override func willDisappear() {
        fetchTimer?.invalidate()
        fetchTaskArr.forEach { (fetchTask) in
            fetchTask.cancel()
        }
    }
    
    var fetchTaskArr = Array<URLSessionDataTask>()
    
    var fetchTimer: Timer?
    
    fileprivate func startTimer() {
        DispatchQueue.main.async {
            self.fetchTimer?.invalidate();
            self.fetchTimer = Timer.scheduledTimer(withTimeInterval: Double(InterfaceController.isRestMode() ? self.defaults.integer(forKey: InterfaceController.REFRESH_TIME) ?? 5 : 5), repeats: true) { (timer) in
                if InterfaceController.isRestMode(),
                    let measurementDataDictArr = self.defaults.array(forKey: InterfaceController.MEASUREMENT_DATA) as? [[String:Any]],
                    let serverUrl = self.defaults.string(forKey: InterfaceController.SERVER_CONFIG)
                {
                    for index in 0..<measurementDataDictArr.count {
                        if self.fetchTaskArr.count == index || self.fetchTaskArr[index].state == URLSessionTask.State.completed {
                            self.fetchTaskArr.insert(RequestUtil.doGetDataForMainTable(serverUrl, measurementDataDictArr[index], self.table, atSelectedMeasurementIndex: index), at: index)
                            self.fetchTaskArr[index].resume()
                        }
                    }
                } else if InterfaceController.isCloudMode() {
                    if let firestoreData = self.defaults.object(forKey: InterfaceController.FIRESTORE_DATA) as? [[String:String]],
                        let cloudToken = self.defaults.string(forKey: InterfaceController.CLOUD_TOKEN) {
                        for index in 0..<firestoreData.count {
                            self.fetchTaskArr.insert(RequestUtil.doGetCloudDataForMainTable(firestoreData[index], cloudToken, self.table, atSelectedMeasurementIndex: index, self), at: index)
                            self.fetchTaskArr[index].resume()
                        }
                    }
                    
                }
            }
        }
    }
    
    private func setHeaders() {
        for index in 0..<table.numberOfRows {
            if let row = table.rowController(at: index) as? MeasurementRowType,
                let measurementDataDictArr = defaults.array(forKey: InterfaceController.MEASUREMENT_DATA) as? [[String:Any]]
                {
                if InterfaceController.isRestMode() {
                    row.header.setText(measurementDataDictArr[index]["watchTitle"] as? String)
                } else if InterfaceController.isCloudMode() {
                    row.header.setText("☁️")
                }
            }
        }
    }
    
    private func getTemp() {
        self.info.setText("Fetching[\(InterfaceController.isRestMode() ? defaults.integer(forKey: InterfaceController.REFRESH_TIME) ?? 5 : 5)s]...")
        setHeaders()
        if fetchTaskArr.count == 0 {
            //start fetching
            
            if InterfaceController.isRestMode(),
               let measurementDataDictArr = defaults.array(forKey: InterfaceController.MEASUREMENT_DATA) as? [[String:Any]],
                let serverUrl = defaults.string(forKey: InterfaceController.SERVER_CONFIG)
            {
                for index in 0..<measurementDataDictArr.count {
                    self.fetchTaskArr.append(RequestUtil.doGetDataForMainTable(serverUrl, measurementDataDictArr[index], self.table, atSelectedMeasurementIndex: index))
                    self.fetchTaskArr[index].resume()
                }
            } else if InterfaceController.isCloudMode() {
                if let firestoreData = defaults.object(forKey: InterfaceController.FIRESTORE_DATA) as? [[String:String]],
                    let cloudToken = defaults.string(forKey: InterfaceController.CLOUD_TOKEN) {
                    for index in 0..<firestoreData.count {
                        self.fetchTaskArr.append(RequestUtil.doGetCloudDataForMainTable(firestoreData[index], cloudToken, self.table, atSelectedMeasurementIndex: index, self))
                        self.fetchTaskArr[index].resume()
                    }
                }
            }
        }
        
        startTimer()
    }
    
    
    
    @IBAction func onFavoritesMenuItemClick() {
        if InterfaceController.isRestMode() {
            pushController(withName: "FavoritesView", context: nil)
        }
    }
    
    @IBAction func onCloudMenuItemClick() {
        defaults.set(InterfaceController.CLOUD_MODE, forKey: InterfaceController.MODE)
        willDisappear()
        if let firestoreData = defaults.array(forKey: InterfaceController.FIRESTORE_DATA) as? [[String:String]] {
            initShowData(firestoreData.count)
        } else {
            table.setNumberOfRows(0, withRowType: "measurementRowType")
            info.setText("No Cloud Data")
        }
    }
    
    @IBAction func onRESTMenuItemClick() {
        defaults.set(InterfaceController.REST_MODE, forKey: InterfaceController.MODE)
        willDisappear()
        if let measurementDataDictArr = defaults.array(forKey: InterfaceController.MEASUREMENT_DATA) as? [[String:Any]] {
            initShowData(measurementDataDictArr.count)
        } else {
            table.setNumberOfRows(0, withRowType: "measurementRowType")
            info.setText("No config")
        }
        
    }
}
