//
//  DeviceDAO.swift
//  JanOnVal
//
//  Created by Christian Stolz on 26.01.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import Foundation

final class DeviceDAO {
    
    static func getDevices() -> [Device] {
        return [
            Device(id: 1, name: "Gesamt", description: "Janitza electronics GmbH, UMG605", type: "JanitzaUMG605"),
            Device(id: 2, name: "Heizung", description: "Janitza electronics GmbH, UMG605", type: "JanitzaUMG605"),
            Device(id: 3, name: "Temperatur", description: "", type: "XXXManInput"),
        ]
    }
}
