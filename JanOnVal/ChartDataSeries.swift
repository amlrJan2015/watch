//
//  Series.swift
//  JanOnVal
//
//  Created by Andreas M on 02.12.23.
//  Copyright © 2023 Andreas Mueller. All rights reserved.
//

import Foundation

struct Series: Identifiable {
    let timePeriod: String
    let pvData: [ChartData]
    
    var id: String { timePeriod }
}
