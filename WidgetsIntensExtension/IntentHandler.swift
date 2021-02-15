//
//  IntentHandler.swift
//  WidgetsIntensExtension
//
//  Created by Andreas M on 03.10.20.
//  Copyright © 2020 Andreas Mueller. All rights reserved.
//

import Intents

class IntentHandler: INExtension, ComparisonSmallIntentHandling, ComparisonMediumIntentHandling, IndicatorIntentHandling {
    func provideWidgetOptionsCollection(for intent: ComparisonSmallIntent, with completion: @escaping (INObjectCollection<JanitzaMeasurementValue>?, Error?) -> Void) {
        if let sharedUD = UserDefaults(suiteName: "group.measurements") {
            if let data = sharedUD.array(forKey: Measurement.KEY_FOR_USER_DEFAULTS) as? [[String: String]] {
                let HOST = "HOST"
                let PORT = "PORT"
                let PROJECT = "PROJECT"
                let measurements = data.filter({ (measurementsDict) -> Bool in
                    return measurementsDict["measurementValue"]?.contains("ActiveEnergy") ?? false
                }).map { measurement -> JanitzaMeasurementValue in
                    let jm = JanitzaMeasurementValue(identifier: "\(measurement["title"]!) \(measurement["deviceName"]!)[\(measurement["deviceId"]!)]:\(measurement["measurementValue"]!)  \(measurement["measurementType"]!)",
                                                     display: "\(measurement["title"]!) \(measurement["deviceName"]!)[\(measurement["deviceId"]!)]:\(measurement["measurementValue"]!)  \(measurement["measurementType"]!)")
                    
                    jm.measurementType = measurement["measurementType"]!
                    jm.measurementValue = measurement["measurementValue"]!
                    jm.deviceId = measurement["deviceId"]!
                    jm.projectName = measurement[PROJECT]!
                    jm.port = measurement[PORT]!
                    jm.url = measurement[HOST]!
                    jm.title = measurement["title"]!
                    jm.unit2 = measurement["unit2"]!
                    
                    return jm
                }
                
                let collection = INObjectCollection(items: measurements)
                completion(collection, nil)
            } else {
                completion(INObjectCollection(items: []), nil)
            }
            
        } else {
            print("App group failed")
        }
    }
    
    func defaultWidget(for intent: ComparisonSmallIntent) -> JanitzaMeasurementValue? {
        if let sharedUD = UserDefaults(suiteName: "group.measurements") {
            if let data = sharedUD.array(forKey: Measurement.KEY_FOR_USER_DEFAULTS) as? [[String: String]],
               data.count > 0 {
                
                let HOST = "HOST"
                let PORT = "PORT"
                let PROJECT = "PROJECT"
                
                let measurement = data.filter({ (measurementsDict) -> Bool in
                    return measurementsDict["measurementValue"]?.contains("ActiveEnergy") ?? false
                })[0]
                
                let jm = JanitzaMeasurementValue(identifier: "\(measurement["title"]!) \(measurement["deviceName"]!)[\(measurement["deviceId"]!)]:\(measurement["measurementValue"]!)  \(measurement["measurementType"]!)",
                                                 display: "\(measurement["title"]!) \(measurement["deviceName"]!)[\(measurement["deviceId"]!)]:\(measurement["measurementValue"]!)  \(measurement["measurementType"]!)")
                
                jm.measurementType = measurement["measurementType"]!
                jm.measurementValue = measurement["measurementValue"]!
                jm.deviceId = measurement["deviceId"]!
                jm.projectName = measurement[PROJECT]!
                jm.port = measurement[PORT]!
                jm.url = measurement[HOST]!
                jm.title = measurement["title"]!
                jm.unit2 = measurement["unit2"]!
                
                return jm
                
            } else {
                print("no energy measurements")
            }
        } else {
            print("App group failed")
        }
        
        return nil
    }
    
    func provideIndicatorWidgetDataOptionsCollection(for intent: IndicatorIntent, with completion: @escaping (INObjectCollection<JanitzaMeasurementValue>?, Error?) -> Void) {
        if let sharedUD = UserDefaults(suiteName: "group.measurements") {
            if let data = sharedUD.array(forKey: Measurement.KEY_FOR_USER_DEFAULTS) as? [[String: String]] {
                let HOST = "HOST"
                let PORT = "PORT"
                let PROJECT = "PROJECT"
                let measurements = data.filter({ (measurementsDict) -> Bool in
                    return measurementsDict["measurementValue"]?.contains("Power") ?? false
                })
                .map { measurement -> JanitzaMeasurementValue in
                    let jm = JanitzaMeasurementValue(identifier: "\(measurement["title"]!) \(measurement["deviceName"]!)[\(measurement["deviceId"]!)]:\(measurement["measurementValue"]!)  \(measurement["measurementType"]!)",
                                                     display: "\(measurement["title"]!) \(measurement["deviceName"]!)[\(measurement["deviceId"]!)]:\(measurement["measurementValue"]!)  \(measurement["measurementType"]!)")
                    
                    jm.measurementType = measurement["measurementType"]!
                    jm.measurementValue = measurement["measurementValue"]!
                    jm.deviceId = measurement["deviceId"]!
                    jm.projectName = measurement[PROJECT]!
                    jm.port = measurement[PORT]!
                    jm.url = measurement[HOST]!
                    jm.title = measurement["title"]!
                    jm.unit2 = measurement["unit2"]!
                    
                    return jm
                }
                
                let collection = INObjectCollection(items: measurements)
                completion(collection, nil)
            } else {
                completion(INObjectCollection(items: []), nil)
            }
            
        } else {
            print("App group failed")
        }
    }
    
    func provideSecondWidgetOptionsCollection(for intent: ComparisonMediumIntent, with completion: @escaping (INObjectCollection<JanitzaMeasurementValue>?, Error?) -> Void) {
        if let sharedUD = UserDefaults(suiteName: "group.measurements") {
            if let data = sharedUD.array(forKey: Measurement.KEY_FOR_USER_DEFAULTS) as? [[String: String]] {
                let HOST = "HOST"
                let PORT = "PORT"
                let PROJECT = "PROJECT"
                let measurements = data.filter({ (measurementsDict) -> Bool in
                    return measurementsDict["measurementValue"]?.contains("ActiveEnergy") ?? false
                })
                .map { measurement -> JanitzaMeasurementValue in
                    let jm = JanitzaMeasurementValue(identifier: "\(measurement["title"]!) \(measurement["deviceName"]!)[\(measurement["deviceId"]!)]:\(measurement["measurementValue"]!)  \(measurement["measurementType"]!)",
                                                     display: "\(measurement["title"]!) \(measurement["deviceName"]!)[\(measurement["deviceId"]!)]:\(measurement["measurementValue"]!)  \(measurement["measurementType"]!)")
                    
                    jm.measurementType = measurement["measurementType"]!
                    jm.measurementValue = measurement["measurementValue"]!
                    jm.deviceId = measurement["deviceId"]!
                    jm.projectName = measurement[PROJECT]!
                    jm.port = measurement[PORT]!
                    jm.url = measurement[HOST]!
                    jm.title = measurement["title"]!
                    jm.unit2 = measurement["unit2"]!
                    
                    return jm
                }
                
                let collection = INObjectCollection(items: measurements)
                completion(collection, nil)
            } else {
                completion(INObjectCollection(items: []), nil)
            }
            
        } else {
            print("App group failed")
        }
    }
    
    func defaultSecondWidget(for intent: ComparisonMediumIntent) -> JanitzaMeasurementValue? {
        
        if let sharedUD = UserDefaults(suiteName: "group.measurements") {
            if let data = sharedUD.array(forKey: Measurement.KEY_FOR_USER_DEFAULTS) as? [[String: String]],
               data.count > 0 {
                
                let HOST = "HOST"
                let PORT = "PORT"
                let PROJECT = "PROJECT"
                
                let measurement = data.filter({ (measurementsDict) -> Bool in
                    return measurementsDict["measurementValue"]?.contains("ActiveEnergy") ?? false
                })[0]
                
                let jm = JanitzaMeasurementValue(identifier: "\(measurement["title"]!) \(measurement["deviceName"]!)[\(measurement["deviceId"]!)]:\(measurement["measurementValue"]!)  \(measurement["measurementType"]!)",
                                                 display: "\(measurement["title"]!) \(measurement["deviceName"]!)[\(measurement["deviceId"]!)]:\(measurement["measurementValue"]!)  \(measurement["measurementType"]!)")
                
                jm.measurementType = measurement["measurementType"]!
                jm.measurementValue = measurement["measurementValue"]!
                jm.deviceId = measurement["deviceId"]!
                jm.projectName = measurement[PROJECT]!
                jm.port = measurement[PORT]!
                jm.url = measurement[HOST]!
                jm.title = measurement["title"]!
                jm.unit2 = measurement["unit2"]!
                
                return jm
                
            } else {
                print("no energy measurements")
            }
        } else {
            print("App group failed")
        }
        
        return nil
    }
    
    
    override func handler(for intent: INIntent) -> Any {
        return self
    }
    func provideFirstWidgetOptionsCollection(for intent: ComparisonMediumIntent, with completion: @escaping (INObjectCollection<JanitzaMeasurementValue>?, Error?) -> Void) {
        if let sharedUD = UserDefaults(suiteName: "group.measurements") {
            if let data = sharedUD.array(forKey: Measurement.KEY_FOR_USER_DEFAULTS) as? [[String: String]] {
                let HOST = "HOST"
                let PORT = "PORT"
                let PROJECT = "PROJECT"
                let measurements = data.filter({ (measurementsDict) -> Bool in
                    return measurementsDict["measurementValue"]?.contains("ActiveEnergy") ?? false
                }).map { measurement -> JanitzaMeasurementValue in
                    let jm = JanitzaMeasurementValue(identifier: "\(measurement["title"]!) \(measurement["deviceName"]!)[\(measurement["deviceId"]!)]:\(measurement["measurementValue"]!)  \(measurement["measurementType"]!)",
                                                     display: "\(measurement["title"]!) \(measurement["deviceName"]!)[\(measurement["deviceId"]!)]:\(measurement["measurementValue"]!)  \(measurement["measurementType"]!)")
                    
                    jm.measurementType = measurement["measurementType"]!
                    jm.measurementValue = measurement["measurementValue"]!
                    jm.deviceId = measurement["deviceId"]!
                    jm.projectName = measurement[PROJECT]!
                    jm.port = measurement[PORT]!
                    jm.url = measurement[HOST]!
                    jm.title = measurement["title"]!
                    jm.unit2 = measurement["unit2"]!
                    
                    return jm
                }
                
                let collection = INObjectCollection(items: measurements)
                completion(collection, nil)
            } else {
                completion(INObjectCollection(items: []), nil)
            }
            
        } else {
            print("App group failed")
        }
    }
    
    func defaultFirstWidget(for intent: ComparisonMediumIntent) -> JanitzaMeasurementValue? {
        if let sharedUD = UserDefaults(suiteName: "group.measurements") {
            if let data = sharedUD.array(forKey: Measurement.KEY_FOR_USER_DEFAULTS) as? [[String: String]],
               data.count > 0 {
                
                let HOST = "HOST"
                let PORT = "PORT"
                let PROJECT = "PROJECT"
                
                let measurement = data.filter({ (measurementsDict) -> Bool in
                    return measurementsDict["measurementValue"]?.contains("ActiveEnergy") ?? false
                })[0]
                
                let jm = JanitzaMeasurementValue(identifier: "\(measurement["title"]!) \(measurement["deviceName"]!)[\(measurement["deviceId"]!)]:\(measurement["measurementValue"]!)  \(measurement["measurementType"]!)",
                                                 display: "\(measurement["title"]!) \(measurement["deviceName"]!)[\(measurement["deviceId"]!)]:\(measurement["measurementValue"]!)  \(measurement["measurementType"]!)")
                
                jm.measurementType = measurement["measurementType"]!
                jm.measurementValue = measurement["measurementValue"]!
                jm.deviceId = measurement["deviceId"]!
                jm.projectName = measurement[PROJECT]!
                jm.port = measurement[PORT]!
                jm.url = measurement[HOST]!
                jm.title = measurement["title"]!
                jm.unit2 = measurement["unit2"]!
                
                return jm
                
            } else {
                print("no energy measurements")
            }            
        } else {
            print("App group failed")
        }
        
        return nil
    }
}

