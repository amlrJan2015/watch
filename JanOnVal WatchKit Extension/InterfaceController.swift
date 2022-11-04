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
import ClockKit

class InterfaceController: WKInterfaceController, WKExtensionDelegate, WCSessionDelegate {
    
    public static let SERVER_CONFIG = "SERVER_CONFIG"
    public static let MEASUREMENT_DATA = "MEASUREMENT_DATA"
    public static let REFRESH_TIME = "REFRESH_TIME"
    
    public static let CLOUD_TOKEN = "CLOUD_TOKEN"
    public static let FIRESTORE_DATA = "FIRESTORE_DATA"
    public static let CONSUMERS = "CONSUMERS"
    
    
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
        
    var firstRun = true
    
    override func awake(withContext context: Any?) {
        pressed = false
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
        
        let measurementDataDictArr = defaults.array(forKey: InterfaceController.MEASUREMENT_DATA) as? [[String:Any]]
        
        if firstRun && measurementDataDictArr?.filter({ (dict) -> Bool in
            return dict["favorite"] as? Bool ?? false
        }).count ?? 0 > 0 {
            firstRun = false
            pushController(withName: "FavoritesView", context: nil)
        }
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
        if InterfaceController.isCloudMode() {
            if let firestoreDataArr = defaults.object(forKey: InterfaceController.FIRESTORE_DATA) as? [[String:String]] {
                let consumers = defaults.integer(forKey: InterfaceController.CONSUMERS)
                if rowIndex < firestoreDataArr.count {
                    let fsData = firestoreDataArr[rowIndex]
                    if let devName = fsData["deviceName"],
                       let devId = fsData["deviceID"] {
                        pushController(withName: "MeasurementInfo", context: ("\(devName)[\(devId)]", "Energy"))
                    } else {
                        pushController(withName: "MeasurementInfo", context: ("unknown", "unknown"))
                    }
                    
                } else {
                    let fsData = firestoreDataArr[rowIndex % consumers]
                    if let devName = fsData["deviceName"],
                        let devId = fsData["deviceID"] {
                        pushController(withName: "MeasurementInfo", context: ("\(devName)[\(devId)]", "Power Active SUM13"))
                    }
                }
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        NSLog("%@", "state: \(activationState.rawValue) error:\(String(describing: error))")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        let measurementDataDictArr = (message["measurementDataDictArr"] as? [[String:Any]])!
        
        let serverUrl = message["serverUrl"] as? String
        let refreshTime = message["refreshTime"] as? Int ?? 3
        
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
            let refreshTime = userInfo["refreshTime"] as? Int ?? 3
            
            defaults.set(serverUrl, forKey: InterfaceController.SERVER_CONFIG)
            defaults.set(measurementDataDictArrGranted, forKey: InterfaceController.MEASUREMENT_DATA)
            defaults.set(refreshTime, forKey: InterfaceController.REFRESH_TIME)
            
            initShowDataForMode()
        }
        
        if let cloudToken = userInfo["cloudToken"] as? String,
            let firestoreData = userInfo["firestoreData"] as? [[String:String]],
            let consumers = userInfo["consumers"] as? Int
        {
            defaults.set(cloudToken, forKey: InterfaceController.CLOUD_TOKEN)
            defaults.set(firestoreData, forKey: InterfaceController.FIRESTORE_DATA)
            defaults.set(consumers, forKey: InterfaceController.CONSUMERS)
            
            initShowDataForMode()
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
        
        pressed = false
        
        session = WCSession.default
        session?.delegate = self
        if session?.activationState != WCSessionActivationState.activated {
            session?.activate()
        }
        
        if InterfaceController.isRestMode() {
            let serverUrl = defaults.string(forKey: InterfaceController.SERVER_CONFIG)
            let measurementDataDictArr = defaults.array(forKey: InterfaceController.MEASUREMENT_DATA) as? [[String:Any]]
            var refreshTime = defaults.integer(forKey: InterfaceController.REFRESH_TIME)
            refreshTime = refreshTime == 0 ? 3 : refreshTime
            
            if serverUrl != nil && measurementDataDictArr != nil {
                if table.numberOfRows != measurementDataDictArr?.count{
                    table.setNumberOfRows(measurementDataDictArr!.count, withRowType: "measurementRowType")
                }
                
                getTemp()
            } else {
                info.setText("No config")
            }
        } else if InterfaceController.isCloudMode() {
            if let firestoreData = defaults.object(forKey: InterfaceController.FIRESTORE_DATA) as? [[String:String]]
            {
                let consumers = defaults.integer(forKey: InterfaceController.CONSUMERS)
                if table.numberOfRows != firestoreData.count + consumers {
                    table.setNumberOfRows(firestoreData.count + consumers, withRowType: "measurementRowType")
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
            self.fetchTimer = Timer.scheduledTimer(withTimeInterval: Double(InterfaceController.isRestMode() ? self.defaults.integer(forKey: InterfaceController.REFRESH_TIME) : 3), repeats: true) { (timer) in
                self.prepareFetchTasks(true)
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
                    if let firestoreData = defaults.object(forKey: InterfaceController.FIRESTORE_DATA) as? [[String:String]] {
                        if index<firestoreData.count {
                            row.header.setText("☁️")
                        } else {
                            row.header.setText("⚡️")
                        }
                    } else {
                        row.header.setText("☁️")
                    }
                }
            }
        }
    }
    
    fileprivate func prepareFetchTasks(_ insert: Bool) {
        //start fetching
        
        if InterfaceController.isRestMode(),
            let measurementDataDictArr = defaults.array(forKey: InterfaceController.MEASUREMENT_DATA) as? [[String:Any]],
            let serverUrl = defaults.string(forKey: InterfaceController.SERVER_CONFIG)
        {
            for index in 0..<measurementDataDictArr.count {
                if insert {
                    self.fetchTaskArr.insert(RequestUtil.doGetDataForMainTable(serverUrl, measurementDataDictArr[index], self.table, atSelectedMeasurementIndex: index), at: index)
                } else {
                    self.fetchTaskArr.append(RequestUtil.doGetDataForMainTable(serverUrl, measurementDataDictArr[index], self.table, atSelectedMeasurementIndex: index))
                }
                
                self.fetchTaskArr[index].resume()
            }
        } else if InterfaceController.isCloudMode() {
            if let firestoreData = defaults.object(forKey: InterfaceController.FIRESTORE_DATA) as? [[String:String]],
                let cloudToken = defaults.string(forKey: InterfaceController.CLOUD_TOKEN) {
                let consumers = defaults.integer(forKey: InterfaceController.CONSUMERS)
                for index in 0..<firestoreData.count/*+consumers*/ {
                    if index < firestoreData.count {
                        let fsData = firestoreData[index]
                        if insert {
                            self.fetchTaskArr.insert(RequestUtil.doGetCloudDataForMainTable(fsData, cloudToken, self.table, atSelectedMeasurementIndex: index, self), at: index)
                        } else {
                            self.fetchTaskArr.append(RequestUtil.doGetCloudDataForMainTable(fsData, cloudToken, self.table, atSelectedMeasurementIndex: index, self))
                        }
                        
                    } else {
                        let fsData = firestoreData[index % consumers]
                        if insert {
                            self.fetchTaskArr.insert(RequestUtil.doGetRealtimeDBDataForMainTable(fsData, cloudToken, self.table, atSelectedMeasurementIndex: index, self), at: index)
                        } else {
                            self.fetchTaskArr.append(RequestUtil.doGetRealtimeDBDataForMainTable(fsData, cloudToken, self.table, atSelectedMeasurementIndex: index, self))
                        }
                    }
                    
                    self.fetchTaskArr[index].resume()
                }
            }
        }
    }
    
    private func getTemp() {
        self.info.setText("Fetching[\(InterfaceController.isRestMode() ? defaults.integer(forKey: InterfaceController.REFRESH_TIME) : 3)s]...")
        setHeaders()
        if fetchTaskArr.count == 0 {
            prepareFetchTasks(false)
        }
        
        startTimer()
    }
    
    
    
    @IBAction func onFavoritesMenuItemClick() {
        if InterfaceController.isRestMode() {
            pushController(withName: "FavoritesView", context: nil)
        }
    }
    
    var pressed = false
    @IBAction func onTableLongPress(_ sender: Any) {
        if !pressed {
            pressed = true
            pushController(withName: "FavoritesView", context: nil)
        }
    }
    
    @IBAction func onCloudMenuItemClick() {
        defaults.set(InterfaceController.CLOUD_MODE, forKey: InterfaceController.MODE)
        willDisappear()
        initShowDataForMode()
    }
    
    @IBAction func onRESTMenuItemClick() {
        defaults.set(InterfaceController.REST_MODE, forKey: InterfaceController.MODE)
        willDisappear()
        initShowDataForMode()
    }
    
    private func initShowDataForMode() {
        if InterfaceController.isRestMode() {
            if let measurementDataDictArr = defaults.array(forKey: InterfaceController.MEASUREMENT_DATA) as? [[String:Any]] {
                initShowData(measurementDataDictArr.count)
            } else {
                table.setNumberOfRows(0, withRowType: "measurementRowType")
                info.setText("No config")
            }
        }
        if InterfaceController.isCloudMode() {
            if let firestoreData = defaults.array(forKey: InterfaceController.FIRESTORE_DATA) as? [[String:String]] {
                let consumers = defaults.integer(forKey: InterfaceController.CONSUMERS)
                initShowData(firestoreData.count + consumers)
            } else {
                table.setNumberOfRows(0, withRowType: "measurementRowType")
                info.setText("No Cloud Data")
            }
        }
    }
}
