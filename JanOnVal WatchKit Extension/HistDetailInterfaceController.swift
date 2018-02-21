//
//  HistDetailInterfaceController.swift
//  JanOnVal WatchKit Extension
//
//  Created by Andreas Müller on 20.02.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import WatchKit
import Foundation


class HistDetailInterfaceController: WKInterfaceController {
    
    @IBOutlet var table: WKInterfaceTable!
    @IBOutlet var tableTitle: WKInterfaceLabel!
    
    let periodArr = ["NAMED_Today", "NAMED_Yesterday", "NAMED_ThisWeek", "NAMED_LastWeek", "NAMED_ThisMonth", "NAMED_LastMonth", "NAMED_ThisYear", "NAMED_LastYear"]
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let dict = context as? [String: Any] {
            self.tableTitle.setText(dict["watchTitle"] as! String)
            table.setNumberOfRows(periodArr.count, withRowType: "histMeasurementRowType")
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
