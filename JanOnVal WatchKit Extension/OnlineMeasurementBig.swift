//
//  OnlineMeasurementBig.swift
//  JanOnVal WatchKit Extension
//
//  Created by Andreas Müller on 22.04.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import UIKit
import WatchKit
import Foundation

class OnlineMeasurementBig: WKInterfaceController {
    
    @IBOutlet var unit: WKInterfaceLabel!
    @IBOutlet var onlineValue: WKInterfaceLabel!
    @IBOutlet var headerEmoji: WKInterfaceLabel!
    
    private var fetchTimer: Timer?
    private var fetchTask: URLSessionDataTask?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let tServerUrl_MeasurementDict = context as? (String,[String: Any]) {
            var settingsDict = tServerUrl_MeasurementDict.1
            
            headerEmoji.setText(settingsDict["watchTitle"] as! String)
            
            DispatchQueue.main.async {
                self.fetchTask = RequestUtil.doGetData(
                    tServerUrl_MeasurementDict.0,
                    settingsDict,
                    self.onlineValue,
                    self.unit)
                self.fetchTask?.resume()
                self.fetchTimer?.invalidate()
                self.fetchTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                    if self.fetchTask?.state == .completed {
                    self.fetchTask = RequestUtil.doGetData(
                        tServerUrl_MeasurementDict.0,
                        settingsDict,
                        self.onlineValue,
                        self.unit)
                    self.fetchTask?.resume()
                    }
                }
            }
        }
    }
    
    override func willDisappear() {
        print("back")
        fetchTimer?.invalidate()
        fetchTask?.cancel()
    }
}
