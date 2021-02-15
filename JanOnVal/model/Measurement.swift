//
//  JanMeasurement.swift
//  JanOnVal
//
//  Created by Andreas Mueller on 28.01.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import Foundation
import os.log
//hist/values

//<value>
//<id>510</id>
//<online>true</online>
//<timebase>60</timebase>
//<valueType>
//<type>SUM13</type>
//<typeName>Sum L1-L3</typeName>
//<unit>W</unit>
//<value>PowerActive</value>
//<valueName>Active Power</valueName>
//</valueType>
//</value>

class Measurement: NSObject, NSCoding, Decodable {
    
    public static let KEY_FOR_USER_DEFAULTS = "KEY_FOR_USER_DEFAULTS"
    public static let ONLINE = 0, HIST = 1, MI = 2
    
    let valueType: ValueType?
    let online: Bool
    var timebase: Int
    var device: Device?
    
    var watchTitle = "☀️"
    var mode = 0
    var start = PickerData.NAMED + PickerData.startEndArr[0]
    var end = PickerData.NAMED + PickerData.startEndArr[0]
    var unit2 = ""
    var favorite = false
    
    init(valueType: ValueType, online: Bool, timebase: Int, device: Device?,
         watchTitle: String, mode: Int, start: String, end: String, unit2: String, favorite: Bool) {
        self.valueType = valueType
        self.online = online
        self.timebase = timebase
        self.device = device
        self.watchTitle = watchTitle
        self.mode = mode
        self.start = start
        self.end = end
        self.unit2 = unit2
        self.favorite = favorite
    }
    
    
    //MARK: Details
    var selected = false
    var index: Int? = nil
    
    override var hash: Int {
        return self.valueType!.type.hashValue + self.valueType!.value.hashValue + (self.device?.id.hashValue ?? 7)
    }
    
    static func ==(lhs: Measurement, rhs: Measurement) -> Bool {
        return lhs.valueType!.value == rhs.valueType!.value && lhs.valueType!.type == rhs.valueType!.type
            && lhs.device?.id == rhs.device?.id
    }
    
    //hist/values
    
    //<value>
    //<id>510</id>
    //<online>true</online>
    //<timebase>60</timebase>
    //<valueType>
    //<type>SUM13</type>
    //<typeName>Sum L1-L3</typeName>
    //<unit>W</unit>
    //<value>PowerActive</value>
    //<valueName>Active Power</valueName>
    //</valueType>
    //</value>
    init?(json: [String: Any]) {
        guard let online = json["online"] as? Bool,
            let timebase = json["timebase"] as? Int,
            let valueTypeDict = json["valueType"] as? [String: Any]
            else {
                return nil
        }
        
        self.online = online
        self.timebase = timebase
        self.valueType = ValueType(json: valueTypeDict)
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(timebase, forKey: MeasurementPropertyKey.timebase)
        aCoder.encode(online, forKey: MeasurementPropertyKey.online)
        aCoder.encode(valueType, forKey: MeasurementPropertyKey.valueType)
        aCoder.encode(watchTitle, forKey: MeasurementPropertyKey.watchTitle)
        aCoder.encode(mode, forKey: MeasurementPropertyKey.mode)
        aCoder.encode(start, forKey: MeasurementPropertyKey.start)
        aCoder.encode(end, forKey: MeasurementPropertyKey.end)
        aCoder.encode(unit2, forKey: MeasurementPropertyKey.unit2)
        aCoder.encode(device!, forKey: MeasurementPropertyKey.device)
        aCoder.encode(favorite, forKey: MeasurementPropertyKey.favorite)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let valueType = aDecoder.decodeObject(forKey: MeasurementPropertyKey.valueType) as? ValueType
            else {
                os_log("Unable to decode the valueType for a measurement object", log: OSLog.default, type: .debug)
                return nil
        }
        guard let device = aDecoder.decodeObject(forKey: MeasurementPropertyKey.device) as? Device
            else {
                os_log("Unable to decode the device for a measurement object", log: OSLog.default, type: .debug)
                return nil
        }
        guard let watchTitle = aDecoder.decodeObject(forKey: MeasurementPropertyKey.watchTitle) as? String
            else {
                os_log("Unable to decode the watchTitle for a measurement object", log: OSLog.default, type: .debug)
                return nil
        }
        guard let start = aDecoder.decodeObject(forKey: MeasurementPropertyKey.start) as? String
            else {
                os_log("Unable to decode the start for a measurement object", log: OSLog.default, type: .debug)
                return nil
        }
        guard let end = aDecoder.decodeObject(forKey: MeasurementPropertyKey.end) as? String
            else {
                os_log("Unable to decode the end for a measurement object", log: OSLog.default, type: .debug)
                return nil
        }
        guard let unit2 = aDecoder.decodeObject(forKey: MeasurementPropertyKey.unit2) as? String
            else {
                os_log("Unable to decode the unit2 for a measurement object", log: OSLog.default, type: .debug)
                return nil
        }
        
        let timebase = aDecoder.decodeInteger(forKey: MeasurementPropertyKey.timebase)
        let mode = aDecoder.decodeInteger(forKey: MeasurementPropertyKey.mode)
        let online = aDecoder.decodeBool(forKey: MeasurementPropertyKey.online)
        let favorite = aDecoder.decodeBool(forKey: MeasurementPropertyKey.favorite)
        
        self.init(valueType: valueType, online: online, timebase: timebase,
                  device: device, watchTitle: watchTitle, mode: mode, start: start,
                  end: end, unit2: unit2, favorite: favorite)
    }
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("selectedMeasurements")
}
