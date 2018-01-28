//
//  Device.swift
//  JanOnVal
//
//  Created by Christian Stolz on 26.01.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import Foundation

struct Device {
    let id: Int
    let name: String
    let description: String
    let type: String
}

extension Device {
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
        self.description = description
        self.type = type
    }
}
