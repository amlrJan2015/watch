//
//  Measurement.swift
//  JanOnVal
//
//  Created by Andreas Müller on 24.12.18.
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

class ValueType: NSObject, NSCoding, Decodable {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(type, forKey: "type")
        aCoder.encode(typeName, forKey: "typeName")
        aCoder.encode(value, forKey: "value")
        aCoder.encode(valueName, forKey: "valueName")
        aCoder.encode(unit, forKey: "unit")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let value = aDecoder.decodeObject(forKey: "value") as? String
            else {
                os_log("Unable to decode the value for a valueType object", log: OSLog.default, type: .debug)
                return nil
        }
        
        guard let type = aDecoder.decodeObject(forKey: "type") as? String
            else {
                os_log("Unable to decode the type for a valueType object", log: OSLog.default, type: .debug)
                return nil
        }
        
        guard let valueName = aDecoder.decodeObject(forKey: "valueName") as? String
            else {
                os_log("Unable to decode the valueName for a valueType object", log: OSLog.default, type: .debug)
                return nil
        }
        
        guard let typeName = aDecoder.decodeObject(forKey: "typeName") as? String
            else {
                os_log("Unable to decode the typeName for a valueType object", log: OSLog.default, type: .debug)
                return nil
        }
        
        guard let unit = aDecoder.decodeObject(forKey: "unit") as? String
            else {
                os_log("Unable to decode the unit for a valueType object", log: OSLog.default, type: .debug)
                return nil
        }
        
        self.init(value: value, valueName: valueName, type: type, typeName: typeName, unit: unit)
    }
    
    let type: String
    let typeName: String
    let unit: String
    let value: String
    let valueName: String
    
    init(value: String, valueName:String, type: String, typeName: String, unit: String) {
        self.value = value
        self.valueName = valueName
        self.type = type
        self.typeName = typeName
        self.unit = unit
    }
    
    override var hash: Int {
        return self.type.hashValue + self.value.hashValue
    }
    
    static func ==(lhs: ValueType, rhs: ValueType) -> Bool {
        return lhs.value == rhs.value && lhs.type == rhs.type
    }
    
    init?(json: [String: Any]) {
        guard let type = json["type"] as? String,
            let typeName = json["typeName"] as? String,
            let unit = json["unit"] as? String,
            let value = json["value"] as? String,
            let valueName = json["valueName"] as? String
            else {
                return nil
        }
        
        self.type = type
        self.typeName = typeName
        self.unit = unit
        self.value = value
        self.valueName = valueName
    }
   
}
