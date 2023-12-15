//
//  AppDelegate.swift
//  JanOnVal
//
//  Created by Andreas Mueller on 08.12.17.
//  Copyright © 2017 Andreas Mueller. All rights reserved.
//

import UIKit
import WatchConnectivity
import BackgroundTasks
import WidgetKit
//import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,
                   UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    var connectivityHandler: ConnectivityHandler?
    let tabBarController = AppTabBarController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NSKeyedUnarchiver.setClass(Device.self, forClassName: "JanOnVal.Device")
        NSKeyedUnarchiver.setClass(ValueType.self, forClassName: "JanOnVal.ValueType")
        NSKeyedUnarchiver.setClass(Measurement.self, forClassName: "JanOnVal.Measurement")
        
        
        // Override point for customization after application launch.
        if WCSession.isSupported() {
            self.connectivityHandler = ConnectivityHandler()
        } else {
            NSLog("WCSession not supported (iPad?)")
        }
        let initData:[Measurement] = []
        do {
            let unarchivedObject = UserDefaults.standard.data(forKey: Measurement.KEY_FOR_USER_DEFAULTS)
            if unarchivedObject == nil {
                let data = try NSKeyedArchiver.archivedData(withRootObject: initData, requiringSecureCoding: false)
                UserDefaults.standard.set(data, forKey: Measurement.KEY_FOR_USER_DEFAULTS)
            }
        } catch {
            fatalError("Can't encode data: \(error)")
        }
        
        registerForPushNotifications()
       
        
        WidgetCenter.shared.reloadAllTimelines()
        /*let defaultContainer = CKContainer.default()
        let database = defaultContainer.privateCloudDatabase
        
        database.fetch(withRecordID: CKRecord.ID(recordName: "config")) { recordOpt, error in
            if error != nil {
                print("Error:\(error)")
            } else {
                
                if let configRecord = recordOpt {
                    let configRecordReferenz = CKRecord.Reference(record: configRecord, action: CKRecord.ReferenceAction.deleteSelf)
                    let predicate = NSPredicate(format: "config == %@", configRecordReferenz)
                    let sort = NSSortDescriptor(key: "index", ascending: true)
                    let query = CKQuery(recordType: "MeasurementValue", predicate: predicate)
                    
                    database.fetch(withQuery: query) { result in
                        
                        switch result {
                        case .success(let successInfo):
                            print("Fetched size:\(successInfo.matchResults.count)")
                            if let sharedUD = UserDefaults(suiteName: "group.measurements") {
                                do {
                                    //                                    let data = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(UserDefaults.standard.data(forKey: Measurement.KEY_FOR_USER_DEFAULTS)!) as! [Measurement]
                                    let defaults = UserDefaults.standard
                                    let HOST = "HOST"
                                    let PORT = "PORT"
                                    let PROJECT = "PROJECT"
                                    
                                    /*filter({ (measurement) -> Bool in
                                     return measurement.valueType?.value.contains("ActiveEnergy") ?? false || measurement.valueType?.value.contains("Power") ?? false
                                     })
                                     .*/
                                    let arr = successInfo.matchResults.map { measurementValueRecord -> [String: String] in
                                        var d: [String: String] = [:]
                                        do {
                                            d["measurementType"] = try measurementValueRecord.1.get()["measurementType"]
                                            d["measurementValue"] = try measurementValueRecord.1.get()["measurementValue"]
                                            d["deviceId"] = try String(measurementValueRecord.1.get()["deviceId"] as! Int)
                                            d[PROJECT] = configRecord["projectName"]
                                            d[PORT] = configRecord["port"]
                                            d[HOST] = configRecord["serverUrl"]
                                            d["title"] = try measurementValueRecord.1.get()["title"]
                                            d["deviceName"] = try measurementValueRecord.1.get()["deviceName"]
                                            d["unit2"] = try measurementValueRecord.1.get()["unit2"]
                                            d["unit"] = try measurementValueRecord.1.get()["unit"]
                                        } catch {
                                            
                                        }
                                        
                                        return d
                                    }
                                    
                                    sharedUD.set(arr, forKey: Measurement.KEY_FOR_USER_DEFAULTS)
                                } catch {
                                    fatalError("IntentHandler - Can't encode data: \(error)")
                                }
                            } else {
                                print("App group failed")
                            }
                            break
                        case .failure(let error):
                            print("Fetch error: \(error)")
                        }
                        
                        
                        
                    }
                }
                
                
            }
            
            
        }*/
        
        return true
    }
    
    // MARK: - Scheduling Tasks
    
    //    func scheduleAppRefresh() {
    //        let request = BGProcessingTaskRequest(identifier: "de.janitza.ios.gridvis.watch.GriCo.fetchDataForComplication")
    //        request.earliestBeginDate = nil//Date(timeIntervalSinceNow: 15 * 60) // Fetch no earlier than 15 minutes from now
    //        request.requiresExternalPower = false
    //        request.requiresNetworkConnectivity = true
    //
    //        do {
    //            try BGTaskScheduler.shared.submit(request)
    //        } catch {
    //            print("Could not schedule app refresh: \(error)")
    //        }
    //    }
    
    // MARK: - Handling Launch for Tasks
    
    // Fetch the latest feed entries from server.
    //    func handleAppRefresh(task: BGAppRefreshTask) {
    //        scheduleAppRefresh()
    //
    //        let queue = OperationQueue()
    //        queue.maxConcurrentOperationCount = 1
    //
    ////        let context = PersistentContainer.shared.newBackgroundContext()
    ////        let operations = Operations.getOperationsToFetchLatestEntries(using: context, server: server)
    ////        let lastOperation = operations.last!
    //
    //        task.expirationHandler = {
    //            // After all operations are cancelled, the completion block below is called to set the task to complete.
    //            queue.cancelAllOperations()
    //        }
    //
    //        lastOperation.completionBlock = {
    //            task.setTaskCompleted(success: !lastOperation.isCancelled)
    //        }
    //
    //        queue.addOperations(operations, waitUntilFinished: false)
    //    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            // 1. Check if permission granted
            guard granted else { return }
            // 2. Attempt registration for remote notifications on the main thread
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let userData = userInfo["data"] as? [String: Double] {
            if let energy = userData["energy"], let activePower = userData["activePower"] {
                let formatedEnergy: String = String(format: "%.1f", energy)
                let formatedActivePower: String = String(format: "%.1f", activePower)
                sendComplicationUpdate(data: ["energy":formatedEnergy, "activePower": formatedActivePower])
            }
        }
    }
    
    func sendComplicationUpdate(data: [String:String]) {
        let session = WCSession.default
        let count = session.remainingComplicationUserInfoTransfers
        let currentTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let formattedCurrentDate = dateFormatter.string(from: currentTime)
        if session.activationState == .activated && session.isComplicationEnabled {
            
            //            var lastWatchUpdate = (UserDefaults.standard.object(forKey: "lastWatchUpdate") ?? Date()) as! Date
            //            //TODO
            //            lastWatchUpdate.addingTimeInterval(60 * 30)
            //            lastWatchUpdate = lastWatchUpdate.addingTimeInterval(60*2)
            //            if lastWatchUpdate < currentTime {
            session.transferCurrentComplicationUserInfo(["VALUE": data])
            UserDefaults.standard.set(Date(), forKey: "lastWatchUpdate")
            UserDefaults.standard.set("YES \(data) \(count) \(formattedCurrentDate)", forKey: "lastReceiveRemoteNotificationData")
            print(count)
            //            } else {
            //                UserDefaults.standard.set("NO \(data) \(count) \(formattedCurrentDate)", forKey: "lastReceiveRemoteNotificationData")
            //                print("Zu häufig \(lastWatchUpdate)")
            //            }
        } else {
            print("####ERROR: transferCurrentComplicationUserInfo failed")
        }
    }
        
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //         1. Convert device token to string
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        // 2. Print device token to use for PNs payloads
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // 1. Print out error if PNs registration not successful
        print("Failed to register for remote notifications with error: \(error)")
    }
    
}

