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
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var show_6_12_18: WKInterfaceSwitch!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        show_6_12_18.setOn(defaults.bool(forKey: OptionsInterfaceController.SHOW_6_12_18))
    }
    
    
    @IBAction func onShow_6_12_18Change(_ value: Bool) {
        defaults.set(value, forKey: OptionsInterfaceController.SHOW_6_12_18)
    }
    
}
