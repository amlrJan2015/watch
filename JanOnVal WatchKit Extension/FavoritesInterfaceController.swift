//
//  FavoritesInterfaceController.swift
//  JanOnVal WatchKit Extension
//
//  Created by Andreas Müller on 25.01.19.
//  Copyright © 2019 Andreas Mueller. All rights reserved.
//

import WatchKit
import Foundation

//⏳

class FavoritesInterfaceController: WKInterfaceController {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var title1: WKInterfaceLabel!
    
    @IBOutlet weak var value1: WKInterfaceLabel!
    
    @IBOutlet weak var unit1: WKInterfaceLabel!
    
    @IBOutlet weak var title2: WKInterfaceLabel!
    
    @IBOutlet weak var value2: WKInterfaceLabel!
    
    @IBOutlet weak var unit2: WKInterfaceLabel!
    
    @IBOutlet weak var title3: WKInterfaceLabel!
    
    @IBOutlet weak var value3: WKInterfaceLabel!
    
    @IBOutlet weak var unit3: WKInterfaceLabel!
    
    @IBOutlet weak var title4: WKInterfaceLabel!
    
    @IBOutlet weak var value4: WKInterfaceLabel!
    
    @IBOutlet weak var unit4: WKInterfaceLabel!
    
    private var measurementDataDictArr: [[String: Any]]?
    private var serverUrl: String?
    private var refreshTime: Int?
    private var titleArr : [WKInterfaceLabel] = []
    private var valueArr : [WKInterfaceLabel] = []
    private var unitArr : [WKInterfaceLabel] = []
    
    fileprivate func setPropertyAtAll(_ uiElementArr: [WKInterfaceLabel], _ propertyName: String, unitDefaultValue: String = "unit") {
        if let measurementDataDictArr = measurementDataDictArr {
            for favIndex in 0..<measurementDataDictArr.count {
                let measurementDataDict = measurementDataDictArr[favIndex]
                uiElementArr[favIndex].setText(measurementDataDict[propertyName] as! String)
            }
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        titleArr = [title1, title2, title3, title4]
        valueArr = [value1, value2, value3, value4]
        unitArr = [unit1, unit2, unit3, unit4]
        
        serverUrl = defaults.string(forKey: InterfaceController.SERVER_CONFIG)
        let measurementDataDictArrAll = defaults.array(forKey: InterfaceController.MEASUREMENT_DATA) as? [[String:Any]]
        refreshTime = defaults.integer(forKey: InterfaceController.REFRESH_TIME)
        refreshTime = refreshTime == 0 ? 5 : refreshTime
        
        if serverUrl != nil && measurementDataDictArrAll != nil {
            var index = 0
            measurementDataDictArr = measurementDataDictArrAll!.filter({ (dict) -> Bool in
                if let isFavorite = dict["favorite"] as? Bool, isFavorite {
                    index = index + 1
                    return index < 5
                }
                return false;
            })
            
            setPropertyAtAll(titleArr, "watchTitle")
            getTemp()
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
                        self.fetchTaskArr.insert(RequestUtil.doGetData(self.serverUrl, self.measurementDataDictArr![index], self.valueArr[index], self.unitArr[index]), at: index)
                        self.fetchTaskArr[index].resume()
                    }
                }
            }
        }
    }
    
    private func getTemp() {
        if fetchTaskArr.count == 0 {
            //start fetching
            for index in 0..<measurementDataDictArr!.count {
                fetchTaskArr.append(RequestUtil.doGetData(serverUrl, measurementDataDictArr![index], valueArr[index], unitArr[index]))
                fetchTaskArr[index].resume()
            }
        }
        
        startTimer()
    }
    
    
    
    fileprivate func pushToBigViewController(_ index: Int) {
        if let url = serverUrl,
            let arr = measurementDataDictArr, arr.count > index{
            let dict = arr[index]
            
            if TableUtil.HIST == dict["mode"] as! Int {
                pushController(withName: "HistDetail", context: (url, dict))
            } else {
                pushController(withName: "OnlineMeasurementBig", context: (url, dict))
            }
        }
    }
    
    @IBAction func onFav1Click() {
        pushToBigViewController(0)
    }
    @IBAction func onFav2Click() {
        pushToBigViewController(1)
    }
    @IBAction func onFav3Click() {
        pushToBigViewController(2)
    }
    @IBAction func onFav4Click() {
        pushToBigViewController(3)
    }
}
