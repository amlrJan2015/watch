//
//  Measurement.swift
//  JanOnVal
//
//  Created by Christian Stolz on 28.01.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import Foundation
import os.log

//<valuetype>
//<type>L1</type>
//<typeName>L1</typeName>
//<unit>V</unit>
//<value>U_Effective</value>
//<valueName>Voltage effective</valueName>
//</valuetype>
class Measurement: NSObject, NSCoding {
    
    public static let ONLINE = 0, HIST = 1, MI = 2
    
    let type: String
    let typeName: String
    let unit: String
    let value: String
    let valueName: String
    let online: String
    var device: Device?
    
    init(value: String, valueName:String, type: String, typeName: String, unit: String, online: String, device: Device?) {
        self.value = value
        self.valueName = valueName
        self.type = type
        self.typeName = typeName
        self.unit = unit
        self.online = online
        self.device = device
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let valueName = aDecoder.decodeObject(forKey: PropertyKey.name) as? String
            else {
                os_log("Unable to decode the valueName for a measurement object", log: OSLog.default, type: .debug)
                return nil
        }
        guard let typeName = aDecoder.decodeObject(forKey: PropertyKey.type) as? String
            else {
                os_log("Unable to decode the typeName for a measurement object", log: OSLog.default, type: .debug)
                return nil
        }
        guard let unit = aDecoder.decodeObject(forKey: PropertyKey.unit) as? String
            else {
                os_log("Unable to decode the unit for a measurement object", log: OSLog.default, type: .debug)
                return nil
        }
        guard let online = aDecoder.decodeObject(forKey: PropertyKey.online) as? String
            else {
                os_log("Unable to decode the online for a measurement object", log: OSLog.default, type: .debug)
                return nil
        }
        
        self.init(value: "", valueName: valueName, type:"", typeName: typeName, unit: unit, online: online, device: nil)
    }
    
    
    
    
    //MARK: Details
    var selected = false
    var watchTitle = "☀️"
    var mode = 0
    var start = PickerData.NAMED + PickerData.startEndArr[0]
    var end = PickerData.NAMED + PickerData.startEndArr[0]
    var timebase = "60"
    var unit2 = ""
    
    
    override var hashValue: Int {
        return self.type.hashValue + self.value.hashValue
    }
    
    static func ==(lhs: Measurement, rhs: Measurement) -> Bool {
        return lhs.value == rhs.value && lhs.type == rhs.type
    }
    
    init?(json: [String: Any]) {
        guard let type = json["type"] as? String,
            let typeName = json["typeName"] as? String,
            let unit = json["unit"] as? String,
            let value = json["value"] as? String,
            let valueName = json["valueName"] as? String,
            let online = json["online"] as? String
            else {
                return nil
        }
        
        self.type = type
        self.typeName = typeName
        self.unit = unit
        self.value = value
        self.valueName = valueName
        self.online = online
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(valueName, forKey: PropertyKey.name)
        aCoder.encode(typeName, forKey: PropertyKey.type)
        aCoder.encode(unit, forKey: PropertyKey.unit)
        aCoder.encode(online, forKey: PropertyKey.online)
    }
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("selectedMeasurements")
}
