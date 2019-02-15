//
//  OptionsInterfaceController.swift
//  JanOnVal WatchKit Extension
//
//  Created by Andreas Müller on 08.02.19.
//  Copyright © 2019 Andreas Mueller. All rights reserved.
//

import Foundation
import WatchKit


class OptionsInterfaceController: WKInterfaceController {
    
    public static let SHOW_6_12_18 = "SHOW_6_12_18"
    public static let SHOW_6_12_18_defaultValue = true
    
    public static let SHOW_Values_On_Y_Axis = "SHOW_Values_On_Y_Axis"
    public static let SHOW_Values_On_Y_Axis_defaultValue = true
    
    public static let SHOW_DERIVATIVE_CHART = "SHOW_DERIVATIVE_CHART"
    public static let SHOW_DERIVATIVE_CHART_defaultValue = false
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var show_6_12_18: WKInterfaceSwitch!
    
    @IBOutlet weak var showValuesOnYAxis: WKInterfaceSwitch!
    
    @IBOutlet weak var showDerivativeChart: WKInterfaceSwitch!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        show_6_12_18.setOn(defaults.bool(forKey: OptionsInterfaceController.SHOW_6_12_18))
        showValuesOnYAxis.setOn(defaults.bool(forKey: OptionsInterfaceController.SHOW_Values_On_Y_Axis))
        showDerivativeChart.setOn(defaults.bool(forKey: OptionsInterfaceController.SHOW_DERIVATIVE_CHART))
    }
    
    @IBAction func onShow_6_12_18Change(_ value: Bool) {
        defaults.set(value, forKey: OptionsInterfaceController.SHOW_6_12_18)
    }
    
    @IBAction func onShowValuesOnYAxisChange(_ value: Bool) {
        defaults.set(value, forKey: OptionsInterfaceController.SHOW_Values_On_Y_Axis)
    }
    
    @IBAction func onShowDerivativeChartChange(_ value: Bool) {
        defaults.set(value, forKey: OptionsInterfaceController.SHOW_DERIVATIVE_CHART)
    }
    
}
