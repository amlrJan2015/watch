//
//  MeasurementDetailViewController.swift
//  JanOnVal
//
//  Created by Andreas Müller on 15.02.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import UIKit

class MeasurementDetailViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var measurement: Measurement?
    
    @IBOutlet weak var valueName: UILabel!
    @IBOutlet weak var typeName: UILabel!
    @IBOutlet weak var isSelected: UISwitch!
    @IBOutlet weak var watchTitle: UITextField!
    @IBOutlet weak var isOnlineOrHistorrical: UISegmentedControl!
    @IBOutlet weak var start: UIPickerView!
    @IBOutlet weak var end: UIPickerView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        watchTitle.delegate = self
        
        start.delegate = self
        start.dataSource = self
        
        end.delegate = self
        end.dataSource = self
        
        if let measurement = measurement {
            valueName.text = measurement.valueName
            typeName.text = measurement.typeName
            isSelected.isOn = measurement.selected
            watchTitle.text = measurement.watchTitle
            isOnlineOrHistorrical.selectedSegmentIndex = measurement.isOnline ? 0 : 1
            
            if !measurement.isOnline {
                
                if let indexOfStart = PickerData.startEndArr.index(of: String(measurement.start.split(separator: "_")[1])) {
                    start.selectRow(indexOfStart, inComponent: 0, animated: true)
                }
                if let indexOfEnd = PickerData.startEndArr.index(of: String(measurement.end.split(separator: "_")[1])) {
                    end.selectRow(indexOfEnd, inComponent: 0, animated: true)
                }
            }
        }
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PickerData.startEndArr.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return PickerData.startEndArr[row]
    }
    
    
    @IBAction func onSelectedChange(_ sender: UISwitch) {
        measurement?.selected = sender.isOn
    }
    @IBAction func onOnlineOrHistoricalChange(_ sender: UISegmentedControl) {
        measurement?.isOnline = sender.selectedSegmentIndex == 0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView === start {
            measurement?.start = PickerData.NAMED+PickerData.startEndArr[row]
        } else if pickerView === end {
            measurement?.end = PickerData.NAMED+PickerData.startEndArr[row]
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            return
        }
        
        measurement?.watchTitle = watchTitle.text!
    }
}
