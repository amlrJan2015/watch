//
//  WidgetFamily.swift
//  GriCoWidgetExtension
//
//  Created by Andreas M on 15.01.21.
//  Copyright © 2021 Andreas Mueller. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct WidgetFamily: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        EnergySmallWidget()
        EnergyMediumWidget()
        IndicatorWidget()
        
    }
}
