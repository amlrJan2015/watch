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
import FirebaseFirestore
import FirebaseAuth
import FirebaseMessaging
import FirebaseCore
import FirebaseFunctions

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,
    MessagingDelegate,
UNUserNotificationCenterDelegate, GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        guard let janitzaIDApp = FirebaseApp.app(name: "JanitzID") else {
            assert(false,"Could not retrieve secondary app!!!")
            return
        }
        
        Auth.auth(app: janitzaIDApp).signIn(with: credential) { (authResultJanitzaID, error) in
            if let error = error {
                print(error.localizedDescription)
                //                self.showAlert("Error", error.localizedDescription)
                return
            }
            // User is signed in
            // ...
            print("USerID_JanitzaID(lVgE...):",authResultJanitzaID?.user.uid ?? "Error on fetch user id")
            
            
            let functions = Functions.functions(app: janitzaIDApp, region: "europe-west1")
            
            functions.httpsCallable("createCustomAuthToken").call { (resultopt, cloudFunctionCallErrOpt) in
                
                if let cloudFunctionCallErr = cloudFunctionCallErrOpt {
                    print("Error Cloud Function Call", cloudFunctionCallErr.localizedDescription)
                    //                    self.showAlert("Error Cloud Function Call", cloudFunctionCallErr.localizedDescription)
                    return
                }
                
                if let result = resultopt {
                    
                    let customerToken = result.data as! String
                    
                    Auth.auth().signIn(withCustomToken: customerToken) { (authResultCloud, cloudError) in
                        if let cloudError = cloudError {
                            print("Cloud Auth Error", cloudError.localizedDescription, customerToken)
                            //                            self.showAlert("Cloud Auth Error", cloudError.localizedDescription)
                            return
                        }
                        
                        
                        print("USerID_JanitzaCloud(lVgE...):",authResultCloud?.user.uid ?? "Error on fetch user id")
                        
                        
                        //                        self.addUserDataIfOk(authResultCloud)
                        //                        if let authResult = authResultCloud {
                        //
                        //                            let userDevicesDocRef = Firestore.firestore().document("/users/\(authResult.user.uid)");
                        //                            userDevicesDocRef.getDocument { (docSnapshot, error) in
                        //                                let k = (docSnapshot?.data()?["devices"] as? [String:Bool])?.filter {$0.value}.keys
                        //                                if let userRegisteredDevice = k {
                        //                                    let devicePath = Array<String>(userRegisteredDevice)[0]
                        //                                    print(devicePath)
                        //
                        //                                }
                        //                            }
                        //
                        //                        }
                        
                        authResultCloud?.user.getIDTokenForcingRefresh(true, completion: { (cloudToken, error) in
                            if let error = error {
                                print("Error get Cloud token", error.localizedDescription)
                                //                                self.showAlert("Error", error.localizedDescription)
                                return
                            }
                            
                            print("#+#+#+#+#CloudToken:",cloudToken!)
                            let connectivityHandlerOpt = (UIApplication.shared.delegate as? AppDelegate)?.connectivityHandler
                            if let connectivityHandler = connectivityHandlerOpt {
                                if connectivityHandler.session.activationState == .activated {
                                    
                                    if let authRC = authResultCloud {
                                        
                                        Firestore.firestore().collectionGroup("Devices").whereField("owner", isEqualTo: authRC.user.uid).getDocuments { (querySnapshot, devicesErr) in
                                            if let err = devicesErr {
                                                print("Error getting documents: \(err)")
                                            } else {
                                                var firestoreData: [[String:String]] = []
                                                for document in querySnapshot!.documents {
                                                    let data = document.data()
                                                    print("\(document.documentID) => \(data["deviceName"] as! String)")
                                                    let dict: [String:String] = [
                                                        "deviceID": document.documentID,
                                                        "hubID": data["hubId"] as! String,
                                                        "deviceName": data["deviceName"] as! String
                                                    ]
                                                    firestoreData.append(dict)
                                                }
                                                
                                                connectivityHandler.session.transferUserInfo([
                                                    "cloudToken": cloudToken!,
                                                    "firestoreData": firestoreData
                                                ])
                                            }
                                        }
                                    }
                                } else {
                                    print("Error","No connectivityHandler!")
                                    //                                    self.showAlert("Error","No connectivityHandler!")
                                }
                            } else {
                                print("Error","No connectivityHandler!")
                                //                                self.showAlert("Error","No connectivityHandler!")
                            }
                        })
                    }
                }
            }
        }
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
        
        
        // Configure with manual options. Note that projectID and apiKey, though not
        // required by the initializer, are mandatory.
        let secondaryOptions = FirebaseOptions(googleAppID: "1:58546128054:ios:ac97d7a00ec3d0ef639217",
                                               gcmSenderID: "58546128054")
        secondaryOptions.apiKey = "AIzaSyCPvCnCeVghPh9VXWEkRuMT_lliUDQHdpg"
        secondaryOptions.projectID = "janitza-id"
        
        // The other options are not mandatory, but may be required
        // for specific Firebase products.
        secondaryOptions.bundleID = "de.janitza.ios.gridvis.watch"
        //        secondaryOptions.trackingID = "UA-12345678-1"
        secondaryOptions.clientID = "58546128054-7qo2aqmkvcoi2lmkf2612hk77t0at70n.apps.googleusercontent.com"
        secondaryOptions.databaseURL = "https://janitza-id.firebaseio.com"
        secondaryOptions.storageBucket = "janitza-id.appspot.com"
        //        secondaryOptions.androidClientID = "12345.apps.googleusercontent.com"
        //        secondaryOptions.deepLinkURLScheme = "myapp://"
        secondaryOptions.appGroupID = nil
        
        FirebaseApp.configure(name: "JanitzID", options: secondaryOptions)
        guard let janitzaIDApp = FirebaseApp.app(name: "JanitzID") else {
            assert(false,"Could not retrieve secondary app!!!")
            return false
        }
        
        GIDSignIn.sharedInstance().clientID = janitzaIDApp.options.clientID
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

