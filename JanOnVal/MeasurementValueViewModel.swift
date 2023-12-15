//
//  MeasurementValueViewModel.swift
//  JanOnVal
//
//  Created by Andreas M on 29.07.22.
//  Copyright © 2022 Andreas Mueller. All rights reserved.
//

import SwiftUI

class MeasurementValueViewModel: ObservableObject {
    private var fetchTimer: Timer?
    private let serverUrl: String
    private let refreshTime: Int
    private let measurementData: [[String:Any]]
    @Published var values: [MeasurementValue]
    @Published var seriesData: [ChartDataSeries]
    
    init(serverUrl:String, refreshTime: Int, measurementData: [[String:Any]]) {
        self.serverUrl = serverUrl
        self.refreshTime = refreshTime
        self.measurementData = measurementData
        self.values = self.measurementData.map({ measurementDataItem in
            let unit1 = (measurementDataItem["unit"] as? String ?? "")
            let unit2 = (measurementDataItem["unit2"] as? String ?? "")
            return MeasurementValue(date: Date(), value: Double.nan, unit: unit2.isEmpty ? unit1 : unit2 , icon: measurementDataItem["watchTitle"] as? String ?? "💡")
        })
        
        self.seriesData = []
        //self.computeChartData(index: 1)
        
        fetchDataWithTimer()
    }
    
    func computeChartData(index: Int) {
        if index != -1 {
            self.seriesData = []
            let mData = measurementData[index]
            let request = MeasurementValueViewModel.createChartRequest(mData, serverUrl, timePeriod: "NAMED_Today")
            let session = URLSession.shared
            session.dataTask(with: request) { data, response, error -> Void in
                do {
                    if let measurementDataJson = data {
                        let json = try JSONSerialization.jsonObject(with: measurementDataJson) as! Dictionary<String, AnyObject>
                        let valuesOpt = json["values"] as? [[String: Any]]
                        
                        if let values = valuesOpt {
                            
                            var serData = ChartDataSeries(timePeriod: "Today", pvData: [])
                            
                            let chartDataToday = values.map({value in
                                let startTime = value["startTime"] as! Int64
                                let endTime = value["endTime"] as! Int64
                                
                                let time = (startTime + endTime) / 2 / 1_000_000_000
                                
                                if let avg = value["avg"] as? Double {
                                    
                                    serData.setMin(value: avg)
                                    serData.setMax(value: avg)
                                    
                                    return ChartData(hour: Date(timeIntervalSince1970: TimeInterval(time)), activePower: avg)
                                }
                                
                                return ChartData(hour: Date(timeIntervalSince1970: TimeInterval(time)), activePower: Double.nan)
                            })
                            DispatchQueue.main.async {
                                var sData = ChartDataSeries(timePeriod: "Today", pvData: chartDataToday)
                                sData.setMax(value: serData.max ?? 0.0)
                                sData.setMin(value: serData.min ?? 0.0)
                                self.seriesData.append(sData)
                            }
                        }
                    }
                } catch {
                    self.seriesData = []
                }
            }.resume()
            
            let requestYesterday = MeasurementValueViewModel.createChartRequest(mData, serverUrl, timePeriod: "NAMED_Yesterday")
            session.dataTask(with: requestYesterday) { data, response, error -> Void in
                do {
                    if let measurementDataJson = data {
                        let json = try JSONSerialization.jsonObject(with: measurementDataJson) as! Dictionary<String, AnyObject>
                        let valuesOpt = json["values"] as? [[String: Any]]
                        if let values = valuesOpt {
                            
                            var serData = ChartDataSeries(timePeriod: "Yesterday", pvData: [])
                            
                            let chartDataYesterday = values.map({value in
                                let startTime = value["startTime"] as! Int64
                                let endTime = value["endTime"] as! Int64
                                
                                let time = (startTime + endTime) / 2 / 1_000_000_000 + (60 * 60 * 24)
                                
                                if let avg = value["avg"] as? Double {
                                    
                                    serData.setMin(value: avg)
                                    serData.setMax(value: avg)
                                    
                                    return ChartData(hour: Date(timeIntervalSince1970: TimeInterval(time)), activePower: avg)
                                }
                                
                                return ChartData(hour: Date(timeIntervalSince1970: TimeInterval(time)), activePower: Double.nan)
                            })
                            DispatchQueue.main.async {
                                var sData = ChartDataSeries(timePeriod: "Yesterday", pvData: chartDataYesterday)
                                sData.setMax(value: serData.max ?? 0.0)
                                sData.setMin(value: serData.min ?? 0.0)
                                self.seriesData.append(sData)
                            }
                        }
                    }
                } catch {
                    self.seriesData = []
                }
            }.resume()
        }
    }
    
    func addMeasurementValue(measurementValue: MeasurementValue) {
        DispatchQueue.main.async { // Correct
            self.values.append(measurementValue)
        }
    }
    
    private static func logC(val: Double, forBase base: Double) -> Double {
        return log(val)/log(base)
    }
    
    public static func getSiPrefix(_ value: Double) -> (String, Double) {
        var result = ("",value)
        
        let pow10 = round(logC(val: abs(value), forBase: 10.0)*100000)/100000
        
        
        if pow10 >= 3.0 {
            result = ("k", value / 1000.0)
        }
        if pow10 >= 6.0 {
            result = ("M", value / 1000_000.0)
        }
        if pow10 >= 9.0 {
            result = ("G", value / 1000_000_000.0)
        }
        if pow10 >= 12.0 {
            result = ("T", value / 1000_000_000_000.0)
        }
        
        return result
    }
    
    private func doGetData(request: URLRequest, index: Int) -> URLSessionDataTask {
        //print("RequestTo:\(request.url)")
        let measurementDataItem = self.measurementData[index]
        let mode = measurementDataItem["mode"] as! Int
        
        let session = URLSession.shared
        
        return session.dataTask(with: request) { data, response, error -> Void in
            
            do {
                
                if let measurementDataJson = data {
                    //                    print(String(data: measurementData,encoding: String.Encoding.utf8) as! String)
                    let json = try JSONSerialization.jsonObject(with: measurementDataJson) as! Dictionary<String, AnyObject>
                    let deviceId = measurementDataItem["deviceId"] as! Int
                    let measurementValue = measurementDataItem["measurementValue"] as! String
                    let measurementType = measurementDataItem["measurementType"] as! String
                    
                    switch mode {
                    case MeasurementValueViewModel.ONLINE:
                        let valmeasurement = json["value"] as? [String: Any]
                        if let value = valmeasurement!["\(deviceId).\(measurementValue).\(measurementType)"] as? Double {
                            DispatchQueue.main.async {
                                self.values[index].value = value
                                self.values[index].date = Date()
                            }
                        } else {
                            DispatchQueue.main.async { // Correct
                                self.values[index].value = Double.nan
                                self.values[index].date = Date()
                            }
                        }
                        break
                    case MeasurementValueViewModel.HIST:
                        if let value = json["energy"] as? Double {
                            DispatchQueue.main.async {
                                self.values[index].value = value
                                self.values[index].date = Date()
                            }
                        } else {
                            DispatchQueue.main.async { // Correct
                                self.values[index].value = Double.nan
                                self.values[index].date = Date()
                            }
                        }
                        break
                    case MeasurementValueViewModel.MI:
                            let valmeasurement = json["details"] as? [String: Any]
                            if let value = valmeasurement!["lastValue"] as? Double {
                                DispatchQueue.main.async { // Correct
                                    self.values[index].value = value
                                    self.values[index].date = Date()
                                }
                            } else {
                                DispatchQueue.main.async { // Correct
                                    self.values[index].value = Double.nan
                                    self.values[index].date = Date()
                                }
                            }
                    default:
                        print("unknown mode")
                    }
                } else {
                    DispatchQueue.main.async { // Correct
                        self.values[index].value = Double.nan
                        self.values[index].date = Date()
                    }
                }
            } catch {
                DispatchQueue.main.async { // Correct
                    self.values[index].value = Double.nan
                    self.values[index].date = Date()
                }
            }
            
        }
    }
    
    var fetchTaskArr = Array<URLSessionDataTask>()
    
    func fetchDataWithTimer() {
        DispatchQueue.main.async {
            let requests = self.measurementData.map { measurementDataItem in
                MeasurementValueViewModel.createRequest(measurementDataItem, self.serverUrl)
            }
            
            requests.enumerated().forEach { (index, request) in
                let task = self.doGetData(request: request, index: index)
                task.resume()
            }
            
            self.fetchTimer?.invalidate()
            self.fetchTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(self.refreshTime), repeats: true) { (timer) in
                requests.enumerated().forEach { (index, request) in
                    let task = self.doGetData(request: request, index: index)
                    task.resume()
                }
            }
        }
    }
    
    public static let ONLINE = 0, HIST = 1, MI = 2
    
    public static func createRequest(_ measurementData:[String: Any], _ serverUrl: String?) -> URLRequest {
        let deviceId = measurementData["deviceId"] as! Int
        let measurementValue = measurementData["measurementValue"] as! String
        let measurementType = measurementData["measurementType"] as! String
        let mode = measurementData["mode"] as! Int
        let timebase = measurementData["timebase"] as! String
        let start = measurementData["start"] as! String
        let end = measurementData["end"] as! String
        
        var requestData = ""
        switch mode {
        case ONLINE:
            requestData = "onlinevalues?value=\(deviceId);\(measurementValue);\(measurementType)"
        case HIST:
            requestData = "devices/\(deviceId)/hist/energy/\(measurementValue)/\(measurementType)?start=\(start)&end=\(end)"
        case MI://
            requestData = "devices/\(deviceId)/manualinput/\(measurementValue)/\(measurementType)/\(timebase)"
        default:
            requestData = "unknown mode"
        }
        
        //print("\(serverUrl!)\(requestData)")
        
        var request = URLRequest(url: URL(string:"\(serverUrl!)\(requestData)")!)
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    
    public static func createChartRequest(_ measurementData:[String: Any], _ serverUrl: String?, timePeriod: String) -> URLRequest {
        let deviceId = measurementData["deviceId"] as! Int
        let measurementValue = measurementData["measurementValue"] as! String
        let measurementType = measurementData["measurementType"] as! String
        
        let timebase = measurementData["timebase"] as! String
        let start = measurementData["start"] as! String
        let end = measurementData["end"] as! String
        let isOnline = measurementData["isOnline"] as! Bool
        
        var requestData = "devices/\(deviceId)/hist/values/\(measurementValue)/\(measurementType)/\(timebase)?start=\(timePeriod)&end=\(timePeriod)&online=\(isOnline)"
        
        print("Chart request: \(serverUrl!)\(requestData)")
        
        var request = URLRequest(url: URL(string:"\(serverUrl!)\(requestData)")!)
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    
    public func cancelTimer() {
        self.fetchTimer?.invalidate()
    }
}
