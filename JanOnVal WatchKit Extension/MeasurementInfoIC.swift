//
//  MeasurementInfoIC.swift
//  JanOnVal WatchKit Extension
//
//  Created by Andreas Müller on 13.11.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import WatchKit
import Foundation


class MeasurementInfoIC: WKInterfaceController {
    
    
    @IBOutlet weak var devInfo: WKInterfaceLabel!
    
    
    @IBOutlet weak var measurementInfo: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let infoContext = context as? (String, String) {
            devInfo.setText(infoContext.0)
            measurementInfo.setText(infoContext.1)
        }
            
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
