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
        WKExtension.shared().registerForRemoteNotifications()
        
        print("try get data from forestore")
        
        let devicePath = "Hub/83fd905cab465569049238e7d0b66c29/Devices/7201:3322"
        var request = URLRequest(url: URL(string:"https://firestore.googleapis.com/v1/projects/gridvis-cloud-bd455/databases/(default)/documents/\(devicePath)")!)
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6ImFmMDg2ZmE4Y2Q5NDFlMDY3ZTc3NzNkYmIwNDcxMjAxMTBlMDA1NGEiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiQW5kcmVhcyBNw7xsbGVyIiwicGljdHVyZSI6Imh0dHBzOi8vbGgzLmdvb2dsZXVzZXJjb250ZW50LmNvbS9hLS9BQXVFN21CRVlTSTBpYkY4Vk5aQnJaaDlhUWZSeTFSRDZGc2hTOXU4RDVqenh3IiwiaXNzIjoiaHR0cHM6Ly9zZWN1cmV0b2tlbi5nb29nbGUuY29tL2dyaWR2aXMtY2xvdWQtYmQ0NTUiLCJhdWQiOiJncmlkdmlzLWNsb3VkLWJkNDU1IiwiYXV0aF90aW1lIjoxNTk2NjE5MjQ5LCJ1c2VyX2lkIjoibFZnRXFPYTdXVll3MHY0ZHN4OHBkNXVvUVhxMSIsInN1YiI6ImxWZ0VxT2E3V1ZZdzB2NGRzeDhwZDV1b1FYcTEiLCJpYXQiOjE1OTY2MTkyNDksImV4cCI6MTU5NjYyMjg0OSwiZW1haWwiOiJhbmRyZWFzLm11ZWxsZXJAamFuaXR6YS5kZSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7Imdvb2dsZS5jb20iOlsiMTE4MjcyMjY2Mjg1NDY1ODUyOTczIl0sImVtYWlsIjpbImFuZHJlYXMubXVlbGxlckBqYW5pdHphLmRlIl19LCJzaWduX2luX3Byb3ZpZGVyIjoiZ29vZ2xlLmNvbSJ9fQ.nYSVXUmyoiM-snff_HOAxpwz5mmn4pOgRG9DHAp1VD-f4dgEp34wI1OO7x8zEYBr2kFHiI6404kBi9LdKCQOBCCou6KPv3NPgV6z4oiOS93O348vQ9KiCQhuDeyyk5MuvE6Y76IQGBqXUSm6R9jORT_qEy0b5gM9dhM_68Uep8D9Ju15P0B6vsejx0FzKjWAPTOTJujfTaYn7dKIMfvuw1ENd3YArwgcIEngY6IGKxHErvYxjSzbI6F9Pg0BwPakobaoqy6iTuUWjNyoKRUkdsOLqubSS5Rmm2Tkb_lVJ9iayRS0bf6cE4Wg3t1vCAWgEGK4MVIEuthsdYPUrQpK_w", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error -> Void in
            print("task is ready")
            do {
                if let measurementDataJson = data {
                    //                    print(String(data: measurementData,encoding: String.Encoding.utf8) as! String)
                    let json = try JSONSerialization.jsonObject(with: measurementDataJson) as! Dictionary<String, AnyObject>
                    let fields = json["fields"] as! [String: Any]
                    let energy = fields["energy"] as! [String: Any]
                    let energyMapValues = energy["mapValue"] as! [String: Any]
                    let energyMapValuesFields = energyMapValues["fields"] as! [String: Any]
                    let eNow = energyMapValuesFields["2020-07-31"] as! [String: Any]
                    var eNowValue = "error"
                    if let intValue = eNow["integerValue"] {
                        eNowValue = intValue as! String
                    }
                    if let doubleValue = eNow["doubleValue"] {
                        eNowValue = doubleValue as! String
                    }
                    print(eNowValue)
                }
            } catch {
                print("error!!!")
            }
            
        }
        
        task.resume()
        
        
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
        
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        WKExtension.shared().isFrontmostTimeoutExtended = true;
        
        session = WCSession.default
        session?.delegate = self
        session?.activate()
        
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
}
