//
//  EnergyValueManager.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.02.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import Foundation

struct EnergyValueManager {
    private static func getRequest(_ url : String) -> URLRequest {
        var request = URLRequest(url: URL(string: url)!)
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    private static func getUrl(widget: JanitzaMeasurementValue?, start: String, end: String) -> String {
        let projectName = (widget?.projectName ?? "").addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        
        return "\(widget?.url ?? ""):\(widget?.port ?? "")/rest/1/projects/\(projectName!)/devices/\(widget?.deviceId ?? "")/hist/energy/\(widget?.measurementValue ?? "")/\(widget?.measurementType ?? "")?start=\(start)&end=\(end)"
    }
    
    /*-----------------------------------SMALL------------------------------*/
    
    static func fetchSmallEnergy(configuration: ComparisonSmallIntent, complete: @escaping (EnergySmallEntry) -> Void) {
        let date = Date()
        let endYesterdayNamed = "NAMED_Yesterday"
        let sComparison = configuration.smartComparison ?? 0 == 1
        
        var dateComponent = DateComponents()
        dateComponent.hour = -24
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: dateComponent, to: date)!
        
        let ns = Int(yesterday.timeIntervalSince1970) * 1000
        let endYesterdayUTC = "UTC_\(ns)"
        
        let endYesterday = sComparison ? endYesterdayUTC : endYesterdayNamed
        
        let urlWidgetToday = getUrl(widget: configuration.widget, start: "NAMED_Today", end: "NAMED_Today")
        let urlWidgetYesterday = getUrl(widget: configuration.widget, start: "NAMED_Yesterday", end: endYesterday)
        
        let urls = [urlWidgetToday, urlWidgetYesterday]
        
        let group = DispatchGroup()
        var results: [Int:Foundation.Data] = [:]        
        
        for urlIndex in 0..<urls.count {
            group.enter()
            let task = URLSession.shared.dataTask(with: getRequest(urls[urlIndex])) { (data, response, error) in
                guard error == nil else {
                    complete(EnergySmallEntry(configuration: configuration, date: date,
                                              mesurementValueToday: MeasurementValue(date: date, value: Double.nan, unit: ""),
                                              mesurementValueYesterday: MeasurementValue(date: date, value: Double.nan, unit: "")))
                    return
                }
                results[urlIndex] = data!
                group.leave()
            }
            task.resume()
        }
        
        group.notify(queue: .main) {
            let energy = getSmallEnergy(configuration: configuration, results: results)
            complete(energy)
        }
        
    }
    static func getSmallEnergy(configuration: ComparisonSmallIntent,  results: [Int:Foundation.Data]) -> EnergySmallEntry {
        let date = Date()
        
        let jsonToday = try! JSONSerialization.jsonObject(with: results[0]!, options: []) as! [String: Any]
        let jsonYesterday = try! JSONSerialization.jsonObject(with: results[1]!, options: []) as! [String: Any]
        
        if let valueToday = jsonToday["energy"] as? Double,
           let valueYesterday = jsonYesterday["energy"] as? Double
        {
            let unit = configuration.widget?.unit2 ?? ""
            return EnergySmallEntry(configuration: configuration, date: date,
                                    mesurementValueToday: MeasurementValue(date: date, value: valueToday, unit: unit.count > 0 ? unit : "Wh"),
                                    mesurementValueYesterday: MeasurementValue(date: date, value: valueYesterday, unit: unit.count > 0 ? unit : "Wh"))
        }
        
        return EnergySmallEntry(configuration: configuration, date: date,
                                mesurementValueToday: MeasurementValue(date: date, value: Double.nan, unit: ""),
                                mesurementValueYesterday: MeasurementValue(date: date, value: Double.nan, unit: ""))
    }
    
    /*-----------------------------------MEDIUM------------------------------*/
    static func fetchMediumEnergy(configuration: ComparisonMediumIntent, complete: @escaping (EnergyMediumEntry) -> Void) {
        
        let date = Date()
        
        let lastYear = ViewModeList.extendedComparisonLastYear == configuration.viewMode
        let sComparison = configuration.smartComparison ?? 0 == 1
        
        let startToday = "NAMED_Today"
        let endToday = "NAMED_Today"
        let startYesterday = "NAMED_Yesterday"
        let endYesterdayNamed = "NAMED_Yesterday"
        
        let periodArr = ["NAMED_ThisWeek", "NAMED_LastWeek", "NAMED_ThisMonth", "NAMED_LastMonth", "NAMED_ThisYear", "NAMED_LastYear"]
        
        var dateComponent = DateComponents()
        dateComponent.hour = -24
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: dateComponent, to: date)!
        
        let ns = Int(yesterday.timeIntervalSince1970) * 1000
        let endYesterdayUTC = "UTC_\(ns)"
        
        let endYesterday = sComparison ? endYesterdayUTC : endYesterdayNamed
        
        let urlFirstWidgetToday = getUrl(widget: configuration.firstWidget, start: startToday, end: endToday)
        let urlFirstWidgetYesterday = getUrl(widget: configuration.firstWidget, start: startYesterday, end: endYesterday)
        
        var urls = [urlFirstWidgetToday, urlFirstWidgetYesterday]
        
        if configuration.viewMode == ViewModeList.extendedComparison || configuration.viewMode == ViewModeList.extendedComparisonLastYear {
            if configuration.smartComparison ?? 0 == 0 {
                if configuration.viewMode == ViewModeList.extendedComparison {
                    for str in periodArr {
                        urls.append(getUrl(widget: configuration.firstWidget, start: str, end: str))
                    }
                } else if configuration.viewMode == ViewModeList.extendedComparisonLastYear {
                    for idx in 0..<periodArr.count {
                        if idx == 1 {
                            let lastYearWeekBegin = EnergyCommon.getDateForLastYear(date: EnergyCommon.getStartOfWeek(date: date), setTo0: true)
                            dateComponent = DateComponents()
                            dateComponent.day = 7
                            let lastYearWeekEnd = Calendar.current.date(byAdding: dateComponent, to: lastYearWeekBegin)!
                            urls.append(getUrl(widget: configuration.firstWidget,
                                               start: EnergyCommon.getUTCDateStringForLastYear(date: EnergyCommon.getStartOfWeek(date: date), setTo0: true),
                                               end: EnergyCommon.getUTCDateString(date: lastYearWeekEnd)))
                        } else if idx == 3 {
                            let lastYearMonthBegin = EnergyCommon.getDateForLastYear(date: EnergyCommon.getStartOfMonth(date: date), setTo0: true)
                            dateComponent = DateComponents()
                            dateComponent.month = 1
                            let lastYearMonthEnd = Calendar.current.date(byAdding: dateComponent, to: lastYearMonthBegin)!
                            urls.append(getUrl(widget: configuration.firstWidget,
                                               start: EnergyCommon.getUTCDateStringForLastYear(date: EnergyCommon.getStartOfMonth(date: date), setTo0: true),
                                               end: EnergyCommon.getUTCDateString(date: lastYearMonthEnd)))
                        } else {
                            urls.append(getUrl(widget: configuration.firstWidget, start: periodArr[idx], end: periodArr[idx]))
                        }
                    }
                }
                
            } else {
                let calendar = Calendar.current
                //Week
                dateComponent = DateComponents()
                dateComponent.day = -7
                var last = calendar.date(byAdding: dateComponent, to: Date())!
                var ns = Int(last.timeIntervalSince1970) * 1000
                var endLastUTC = "UTC_\(ns)"
                
                urls.append(getUrl(widget: configuration.firstWidget, start: periodArr[0], end: periodArr[0]))
                urls.append(getUrl(widget: configuration.firstWidget, start: lastYear ? EnergyCommon.getUTCDateStringForLastYear(date: EnergyCommon.getStartOfWeek(date: date), setTo0: true) : periodArr[1], end: lastYear ? EnergyCommon.getUTCDateStringForLastYear(date: Date(), setTo0: false) : endLastUTC))
                
                //Month
                dateComponent = DateComponents()
                dateComponent.month = -1
                last = calendar.date(byAdding: dateComponent, to: Date())!
                ns = Int(last.timeIntervalSince1970) * 1000
                endLastUTC = "UTC_\(ns)"
                urls.append(getUrl(widget: configuration.firstWidget, start: periodArr[2], end: periodArr[2]))
                urls.append(getUrl(widget: configuration.firstWidget, start: lastYear ? EnergyCommon.getUTCDateStringForLastYear(date: EnergyCommon.getStartOfMonth(date: date), setTo0: true) : periodArr[3], end: lastYear ? EnergyCommon.getUTCDateStringForLastYear(date: Date(), setTo0: false) : endLastUTC))
                
                //Year
                dateComponent = DateComponents()
                dateComponent.year = -1
                last = calendar.date(byAdding: dateComponent, to: Date())!
                ns = Int(last.timeIntervalSince1970) * 1000
                endLastUTC = "UTC_\(ns)"
                urls.append(getUrl(widget: configuration.firstWidget, start: periodArr[4], end: periodArr[4]))
                urls.append(getUrl(widget: configuration.firstWidget, start: periodArr[5], end: endLastUTC))
            }
        } else if configuration.viewMode == ViewModeList.twoWidgets {
            urls.append(getUrl(widget: configuration.secondWidget, start: startToday, end: endToday))
            urls.append(getUrl(widget: configuration.secondWidget, start: startYesterday, end: endYesterday))
        }
        
        
        let group = DispatchGroup()
        var results: [Int:Foundation.Data] = [:]
        
        for urlIndex in 0..<urls.count {
            group.enter()
            let task = URLSession.shared.dataTask(with: getRequest(urls[urlIndex])) { (data, response, error) in
                guard error == nil else {
                    complete(EnergyMediumEntry(configuration: configuration, date: date,
                                               firstWidgetMVToday: MeasurementValue(date: date, value: Double.nan, unit: ""),
                                               firstWidgetMVYesterday: MeasurementValue(date: date, value: Double.nan, unit: ""),
                                               secondWidgetMVToday: MeasurementValue(date: date, value: Double.nan, unit: ""),
                                               secondWidgetMVYesterday: MeasurementValue(date: date, value: Double.nan, unit: ""), extendedComparisonValues: nil))
                    return
                }
                results[urlIndex] = data!
                group.leave()
            }
            task.resume()
        }
        
        group.notify(queue: .main) {
            let energy = getMediumEnergy(configuration: configuration, results: results)
            complete(energy)
        }
        
    }
    
    static func getMediumEnergy(configuration: ComparisonMediumIntent,  results: [Int:Foundation.Data]) -> EnergyMediumEntry {
        let date = Date()
                
        let jsonToday = try! JSONSerialization.jsonObject(with: results[0]!, options: []) as! [String: Any]
        let jsonYesterday = try! JSONSerialization.jsonObject(with: results[1]!, options: []) as! [String: Any]
        let jsonPVToday = try! JSONSerialization.jsonObject(with: results[2]!, options: []) as! [String: Any]
        let jsonPVYesterday = try! JSONSerialization.jsonObject(with: results[3]!, options: []) as! [String: Any]
        
        if let valueToday = jsonToday["energy"] as? Double,
           let valueYesterday = jsonYesterday["energy"] as? Double,
           let valueSecondToday = jsonPVToday["energy"] as? Double,
           let valueSecondYesterday = jsonPVYesterday["energy"] as? Double
        {
            let firstUnit = configuration.firstWidget?.unit2 ?? ""
            let secondUnit = configuration.secondWidget?.unit2 ?? ""
            var energyEntry = EnergyMediumEntry(configuration: configuration, date: date,
                                                firstWidgetMVToday: MeasurementValue(date: date, value: valueToday, unit: firstUnit.count > 0 ? firstUnit : "Wh"),
                                                firstWidgetMVYesterday: MeasurementValue(date: date, value: valueYesterday, unit: firstUnit.count > 0 ? firstUnit : "Wh"),
                                                secondWidgetMVToday: MeasurementValue(date: date, value: valueSecondToday, unit: secondUnit.count > 0 ? secondUnit : "Wh"),
                                                secondWidgetMVYesterday: MeasurementValue(date: date, value: valueSecondYesterday, unit: secondUnit.count > 0 ? secondUnit : "Wh"), extendedComparisonValues: nil)
            
            if configuration.viewMode == ViewModeList.extendedComparison || configuration.viewMode == ViewModeList.extendedComparisonLastYear {
                energyEntry.extendedComparisonValues = []
                for resultIndex in 2..<results.count {
                    let json = try! JSONSerialization.jsonObject(with: results[resultIndex]!, options: []) as! [String: Any]
                    if let resultValue = json["energy"] as? Double {
                        energyEntry.extendedComparisonValues!.append(resultValue)
                    } else {
                        energyEntry.extendedComparisonValues!.append(Double.nan)
                    }
                }
            }
            
            return energyEntry
        }
        
        
        
        
        
        return EnergyMediumEntry(configuration: configuration, date: date,
                                 firstWidgetMVToday: MeasurementValue(date: date, value: Double.nan, unit: ""),
                                 firstWidgetMVYesterday: MeasurementValue(date: date, value: Double.nan, unit: ""),
                                 secondWidgetMVToday: MeasurementValue(date: date, value: Double.nan, unit: ""),
                                 secondWidgetMVYesterday: MeasurementValue(date: date, value: Double.nan, unit: ""), extendedComparisonValues: nil)
    }
}
