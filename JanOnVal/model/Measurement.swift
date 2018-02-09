//
//  Measurement.swift
//  JanOnVal
//
//  Created by Christian Stolz on 28.01.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import Foundation

//<valuetype>
//<type>L1</type>
//<typeName>L1</typeName>
//<unit>V</unit>
//<value>U_Effective</value>
//<valueName>Voltage effective</valueName>
//</valuetype>
struct Measurement {
    let type: String
    let typeName: String
    let unit: String
    let value: String
    let valueName: String
    var deviceId = 0
}

extension Measurement: Hashable {
    var hashValue: Int {
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
