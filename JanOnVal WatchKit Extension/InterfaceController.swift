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
    
    var serverUrl: String?
    var refreshTime: Int?
    
    let defaults = UserDefaults.standard
    
    @IBOutlet var info: WKInterfaceLabel!
    
    var measurementDataDictArr: [[String: Any]]?
    
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
        
//        print("try get data from forestore")
//        
//        
//        let cloudToken = defaults.object(forKey: InterfaceController.CLOUD_TOKEN)
//        let firestoreData = defaults.object(forKey: InterfaceController.FIRESTORE_DATA)
//        if cloudToken != nil && firestoreData != nil {
//            
//            let hubID = (firestoreData as! [[String:String]])[0]["hubID"]
//            let deviceID = (firestoreData as! [[String:String]])[0]["deviceID"]
//            let deviceName = (firestoreData as! [[String:String]])[0]["deviceName"]
//            print("Energy for ", deviceName!)
//            let devicePath = "Hub/\(hubID!)/Devices/\(deviceID!)"
//            var request = URLRequest(url: URL(string:"https://firestore.googleapis.com/v1/projects/gridvis-cloud-bd455/databases/(default)/documents/\(devicePath)")!)
//            request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
//            request.httpMethod = "GET"
//            request.setValue("application/json", forHTTPHeaderField: "Accept")
//            
//            request.setValue("Bearer \(cloudToken!)", forHTTPHeaderField: "Authorization")
//            
//            let session = URLSession.shared
//            
//            let task = session.dataTask(with: request) { data, response, error -> Void in
//                print("task is ready")
//                do {
//                    
//                    let statusCode = (response as! HTTPURLResponse).statusCode
//                    
//                    if statusCode == 200 {
//                        if let measurementDataJson = data {
//                            //                    print(String(data: measurementData,encoding: String.Encoding.utf8) as! String)
//                            let json = try JSONSerialization.jsonObject(with: measurementDataJson) as! Dictionary<String, AnyObject>
//                            let fields = json["fields"] as! [String: Any]
//                            let energy = fields["energy"] as! [String: Any]
//                            let energyMapValues = energy["mapValue"] as! [String: Any]
//                            let energyMapValuesFields = energyMapValues["fields"] as! [String: Any]
//                            let eNow = energyMapValuesFields["2020-08-14"] as! [String: Any]
//                            var eNowValue = "error"
//                            if let intValue = eNow["integerValue"] {
//                                eNowValue = intValue as! String
//                            }
//                            if let doubleValue = eNow["doubleValue"] {
//                                eNowValue = doubleValue as! String
//                            }
//                            print(eNowValue)
//                        }
//                    } else if statusCode == 403 || statusCode == 401 {
//                        print("let refresh token")
//                        let action = WKAlertAction(title: "on iPhone",style: WKAlertActionStyle.destructive){}
//                        self.presentAlert(withTitle: "CloudToken", message: "Please refresh Cloud Token!", preferredStyle: WKAlertControllerStyle.alert, actions: [action])
//                    }
//                } catch {
//                    print("error!!!")
//                }
//                
//            }
//            
//            task.resume()
//        } else {
//            let action = WKAlertAction(title: "on iPhone",style: WKAlertActionStyle.destructive){}
//            self.presentAlert(withTitle: "CloudToken", message: "Please refresh Cloud Token!", preferredStyle: WKAlertControllerStyle.alert, actions: [action])
//        }
        
        
    }
    
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        print("REGISTER OK")
    }
    func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
        print("REGISTER FAILED!!!!")
    }
    
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
        NSLog("%@", "state: \(activationState.rawValue) error:\(String(describing: error))")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        measurementDataDictArr = (message["measurementDataDictArr"] as? [[String:Any]])!
        
        //        table.setNumberOfRows(measurementDataDictArr!.count, withRowType: "measurementRowType")
        
        serverUrl = message["serverUrl"] as? String
        refreshTime = message["refreshTime"] as? Int ?? 5
        
        defaults.set(serverUrl, forKey: InterfaceController.SERVER_CONFIG)
        defaults.set(measurementDataDictArr, forKey: InterfaceController.MEASUREMENT_DATA)
        defaults.set(refreshTime, forKey: InterfaceController.REFRESH_TIME)
        
        table.setNumberOfRows(measurementDataDictArr!.count, withRowType: "measurementRowType")
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
            
            measurementDataDictArr = measurementDataDictArrGranted
            
            //        table.setNumberOfRows(measurementDataDictArr!.count, withRowType: "measurementRowType")
            
            serverUrl = userInfo["serverUrl"] as? String
            refreshTime = userInfo["refreshTime"] as? Int ?? 5
            
            defaults.set(serverUrl, forKey: InterfaceController.SERVER_CONFIG)
            defaults.set(measurementDataDictArr, forKey: InterfaceController.MEASUREMENT_DATA)
            defaults.set(refreshTime, forKey: InterfaceController.REFRESH_TIME)
            
            table.setNumberOfRows(measurementDataDictArr!.count, withRowType: "measurementRowType")
            getTemp()
        }
        
        if let cloudToken = userInfo["cloudToken"] as? String,
            let firestoreData = userInfo["firestoreData"] as? [[String:String]] {
            print("CloudToken on Watch", cloudToken)
            print("firestoreData on Watch", firestoreData.count)
            defaults.set(cloudToken, forKey: InterfaceController.CLOUD_TOKEN)
            defaults.set(firestoreData, forKey: InterfaceController.FIRESTORE_DATA)
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        WKExtension.shared().isFrontmostTimeoutExtended = true;
        
        session = WCSession.default
        session?.delegate = self
        //TODO check ob es bereits active ist
        session?.activate()
                
        let mode = defaults.object(forKey: InterfaceController.MODE) as! String
        
        if mode == InterfaceController.REST_MODE {
            
            serverUrl = defaults.string(forKey: InterfaceController.SERVER_CONFIG)
            measurementDataDictArr = defaults.array(forKey: InterfaceController.MEASUREMENT_DATA) as? [[String:Any]]
            refreshTime = defaults.integer(forKey: InterfaceController.REFRESH_TIME)
            refreshTime = refreshTime == 0 ? 5 : refreshTime
            
            if serverUrl != nil && measurementDataDictArr != nil {
                
                if table.numberOfRows != measurementDataDictArr?.count{
                    table.setNumberOfRows(measurementDataDictArr!.count, withRowType: "measurementRowType")
                }
                
                getTemp()
            } else {
                info.setText("No config")
            }
        } else if mode == InterfaceController.CLOUD_MODE {
            if let firestoreData = defaults.object(forKey: InterfaceController.FIRESTORE_DATA) as? [[String:String]] {
                info.setText("Cloud \(firestoreData.count)")
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
    
    private func setHeaders() {
        for index in 0..<table.numberOfRows {
            let row = table.rowController(at: index) as? MeasurementRowType
            row?.header.setText(measurementDataDictArr?[index]["watchTitle"] as? String)
        }
    }
    
    private func getTemp() {
        self.info.setText("Fetching[\(refreshTime!)s]...")
        setHeaders()
        if fetchTaskArr.count == 0 {
            //start fetching
            for index in 0..<self.measurementDataDictArr!.count {
                self.fetchTaskArr.append(RequestUtil.doGetDataForMainTable(self.serverUrl, self.measurementDataDictArr![index], self.table, atSelectedMeasurementIndex: index))
                self.fetchTaskArr[index].resume()
            }
        }
        
        startTimer()
    }
    
    
    
    @IBAction func onFavoritesMenuItemClick() {
        pushController(withName: "FavoritesView", context: nil)
    }
    
    @IBAction func onCloudMenuItemClick() {
        defaults.set(InterfaceController.CLOUD_MODE, forKey: InterfaceController.MODE)
    }
    
    @IBAction func onRESTMenuItemClick() {
        defaults.set(InterfaceController.REST_MODE, forKey: InterfaceController.MODE)
    }
}
