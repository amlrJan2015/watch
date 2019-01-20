//
//  Device.swift
//  JanOnVal
//
//  Created by Christian Stolz on 26.01.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import Foundation
import os.log

class Device: NSObject, NSCoding {
    let id: Int
    let name: String
    let desc: String
    let type: String
    
    init(id: Int, name: String, description: String, type: String) {
        self.id = id
        self.name = name
        self.desc = description
        self.type = type
    }
    
    override var hash: Int {
        return self.id
    }
    
    static func ==(lhs: Device, rhs: Device) -> Bool {
        return lhs.id == rhs.id
    }
    
    init?(json: [String: Any]) {
        guard let name = json["name"] as? String,
            let id = json["id"] as? Int,
            let description = json["description"] as? String,
            let type = json["type"] as? String
            else {
                return nil
        }
        
        self.name = name
        self.id = id
        self.desc = description
        self.type = type
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: DevicePropertyKey.id)
        aCoder.encode(name, forKey: DevicePropertyKey.name)
        aCoder.encode(desc, forKey: DevicePropertyKey.description)
        aCoder.encode(type, forKey: DevicePropertyKey.type)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeInteger(forKey: DevicePropertyKey.id)
        guard let name = aDecoder.decodeObject(forKey: DevicePropertyKey.name) as? String
            else {
                os_log("Unable to decode the name for a device object", log: OSLog.default, type: .debug)
                return nil
        }
        guard let description = aDecoder.decodeObject(forKey: DevicePropertyKey.description) as? String
            else {
                os_log("Unable to decode the description for a device object", log: OSLog.default, type: .debug)
                return nil
        }
        guard let type = aDecoder.decodeObject(forKey: DevicePropertyKey.type) as? String
            else {
                os_log("Unable to decode the type for a device object", log: OSLog.default, type: .debug)
                return nil
        }
        
        
        self.init(id: id, name: name, description: description, type: type)
    }
}
