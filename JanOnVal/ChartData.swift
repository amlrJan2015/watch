//
//  ChartData.swift
//  JanOnVal
//
//  Created by Andreas M on 02.12.23.
//  Copyright © 2023 Andreas Mueller. All rights reserved.
//

import Foundation

struct ChartData: Identifiable {
    let hour: Date
    let activePower: Double
    
    var id: Date { hour }
}
