//
//  InterfaceController.swift
//  JanOnVal WatchKit Extension
//
//  Created by Christian Stolz on 08.12.17.
//  Copyright © 2017 Andreas Mueller. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WKExtensionDelegate, WCSessionDelegate {
    
    //let tempRestURL = URL(string: "http://www.zum-eisenberg.de:8080/rest/1/projects/Eisenberg/onlinevalues?value=1;Temperature;Temp_Extern1")!
    
    var endPoint1: String?
    var endPoint2: String?
    
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
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        self.endPoint1 = (message["ep1"] as? String)
        self.endPoint2 = (message["ep2"] as? String)
        self.serverUrl = (message["serverUrl"] as! String)
        NSLog("%@", "ep1:\(self.endPoint1) server:\(self.serverUrl)")
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
    }
    
    
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    var fetchTask1: URLSessionDataTask!
    var fetchTask2: URLSessionDataTask!
    
    func doGetData1()->URLSessionDataTask {
        var request = URLRequest(url: URL(string:"\(self.serverUrl!)\(self.endPoint1!)")!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        return session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                DispatchQueue.main.async { // Correct
                    guard let value = json["value"] as? [String: Any],
                        let t = value["1.Temperature.Temp_Extern1"] as? Double else {
                            return
                    }
                    print("T:\(t)")
                    self.temperatureLbl.setText(String(format:"W[T]:%.1f˚", t))
                }
            } catch {
                print("error")
            }
            
        })
    }
    
    func doGetData2()->URLSessionDataTask {
        var request = URLRequest(url: URL(string:"\(self.serverUrl!)\(self.endPoint2!)")!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        return session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                DispatchQueue.main.async { // Correct
                    guard let value = json["value"] as? [String: Any],
                        let t = value["1.PowerActive.SUM13"] as? Double else {
                            return
                    }
                    print("T:\(t)")
                    self.ep2.setText(String(format:"Verbr:%.1fW", t))
                }
            } catch {
                print("error")
            }
            
        })
    }

    @IBOutlet var temperatureLbl: WKInterfaceLabel!    
    @IBOutlet var ep2: WKInterfaceLabel!
    
    var fetchTimer: Timer?;
    
    @IBAction func getTemp() {
        temperatureLbl.setText("W[T]:...")
        ep2.setText("Verbr[W]:...")
        
        fetchTimer?.invalidate();
        
        fetchTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (timer) in
            DispatchQueue.main.async { // Correct
                print("get data")
                if self.fetchTask1 == nil || self.fetchTask1.state == URLSessionTask.State.completed {
                    self.fetchTask1 = self.doGetData1()
                    self.fetchTask1.resume()
                }
                if self.fetchTask2 == nil || self.fetchTask2.state == URLSessionTask.State.completed {
                    self.fetchTask2 = self.doGetData2()
                    self.fetchTask2.resume()
                }
            }
        }
    }
}
