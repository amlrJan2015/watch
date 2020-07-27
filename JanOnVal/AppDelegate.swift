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
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,
    MessagingDelegate,
UNUserNotificationCenterDelegate, GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // ...
        if let error = error {
          // ...
          return
        }

        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        // ...
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    var window: UIWindow?
    var connectivityHandler: ConnectivityHandler?
    let tabBarController = AppTabBarController()
    var cloudDB: Firestore!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
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
        
        
        //        BGTaskScheduler.shared.register(forTaskWithIdentifier: "de.janitza.ios.gridvis.watch.GriCo.fetchDataForComplication", using: nil) { task in
        //            // Downcast the parameter to an app refresh task as this identifier is used for a refresh request.
        //            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        //        }
        
        
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
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("FCM token: \(fcmToken)")
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
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

