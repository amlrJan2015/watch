//
//  AppDelegate.swift
//  JanOnVal
//
//  Created by Andreas Mueller on 08.12.17.
//  Copyright © 2017 Andreas Mueller. All rights reserved.
//

import UIKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var connectivityHandler: ConnectivityHandler?
    let tabBarController = AppTabBarController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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
        
        return true
    }
    
}

