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
    @IBOutlet weak var updateState: WKInterfaceLabel!
    @IBOutlet weak var updateStateGroup: WKInterfaceGroup!
    
    
    private var fetchTimer: Timer?
    private var fetchTask: URLSessionDataTask?
    private var dict: [String: Any] = [:]
    private var serverUrl = ""
    
    static var updateStateCounter = 0
    
    fileprivate func fetchAndShowData() {
        headerEmoji.setText((dict["watchTitle"] as! String))
        
        DispatchQueue.main.async {
            self.fetchTask = RequestUtil.doGetData(
                self.serverUrl,
                self.dict,
                self.onlineValue,
                self.unit)
            self.fetchTask?.resume()
            self.fetchTimer?.invalidate()
            self.fetchTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                OnlineMeasurementBig.updateStateCounter += 1
                self.updateState.setText(self.getUpdateStateInfo())
                if self.fetchTask?.state == .completed {
                    self.fetchTask = RequestUtil.doGetData(
                        self.serverUrl,
                        self.dict,
                        self.onlineValue,
                        self.unit)
                    self.fetchTask?.resume()
                }
                
            }
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let tServerUrl_MeasurementDict = context as? (String,[String: Any]) {
            serverUrl = tServerUrl_MeasurementDict.0
            dict = tServerUrl_MeasurementDict.1
        }
    }
    
    @IBAction func onInfoClick() {
        var devName = "No info. Please config the value on iPhone again."
        var mInfo = ""
        if let devNameOpt = dict["deviceName"] as? String {
            devName = devNameOpt
            mInfo = "\(dict["measurementValueName"] as! String)\n\(dict["measurementTypeName"] as! String)"
        }
        
        pushController(withName: "MeasurementInfo", context: (devName, mInfo))
    }
    override func willDisappear() {
        fetchTimer?.invalidate()
        fetchTask?.cancel()
    }
    
    override func willActivate() {
        fetchAndShowData()
    }
    
    //00CC00
    private static let GREEN = UIColor(red: 0.0, green: 204.0/256.0, blue: 0.0, alpha: 1.0)
    //EEBF00
    private static let YELLOW = UIColor(red: 238.0/256.0, green: 191.0/256.0, blue: 0.0, alpha: 1.0)
    //FF0000
    private static let RED = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    
    private func getUpdateStateInfo() -> String {
        let duration = OnlineMeasurementBig.updateStateCounter
        let durationStr = duration > 99 ? "♾" : "\(OnlineMeasurementBig.updateStateCounter)"
        switch duration {
        case 0..<5:
            updateStateGroup.setBackgroundColor(OnlineMeasurementBig.GREEN)
            return durationStr
        case 5..<10:
            updateStateGroup.setBackgroundColor(OnlineMeasurementBig.YELLOW)
            return durationStr
        default:
            updateStateGroup.setBackgroundColor(OnlineMeasurementBig.RED)
            return durationStr
        }
    }
}
