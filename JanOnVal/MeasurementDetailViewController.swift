//
//  MeasurementDetailViewController.swift
//  JanOnVal
//
//  Created by Andreas Müller on 15.02.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import UIKit

class MeasurementDetailViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate {
    
    var measurement: Measurement?
    
    @IBOutlet weak var valueName: UILabel!
    @IBOutlet weak var typeName: UILabel!
    
    @IBOutlet weak var watchTitle: UITextField!
    @IBOutlet weak var isOnlineOrHistorrical: UISegmentedControl!
    @IBOutlet weak var start: UIPickerView!
    @IBOutlet weak var end: UIPickerView!
    @IBOutlet weak var timebase: UITextField!
    @IBOutlet weak var unit2: UITextField!
    
    @IBOutlet weak var favorite: UISwitch!
    @IBOutlet weak var online: UISwitch!
    
    @IBOutlet var gesture: UISwipeGestureRecognizer!
    
    private var savedData = [Measurement]()
    
    @IBAction func onSwipeDown(_ sender: UISwipeGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        watchTitle.delegate = self
        
        start.delegate = self
        start.dataSource = self
        
        end.delegate = self
        end.dataSource = self
        
        gesture.delegate = self
        
        if let measurement = measurement,
            let unarchivedObject = UserDefaults.standard.data(forKey: Measurement.KEY_FOR_USER_DEFAULTS) {
            do{
                savedData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(unarchivedObject) as! [Measurement]
            } catch {
                fatalError("unarchivedObject - Can't encode data: \(error)")
            }
            timebase.text = String(measurement.timebase)
            online.setOn(measurement.online, animated: false)
            
            if let valueType = measurement.valueType {
                
                valueName.text = "\(valueType.valueName) [\(measurement.device?.name ?? "")]"
                typeName.text = valueType.typeName
                
                watchTitle.text = measurement.watchTitle
                
                isOnlineOrHistorrical.selectedSegmentIndex = measurement.mode
                unit2.text = measurement.unit2
                favorite.isOn = measurement.favorite
                
                if measurement.mode == Measurement.HIST {
                    show()
                    if let indexOfStart = PickerData.startEndArr.index(of: String(measurement.start.split(separator: "_")[1])) {
                        start.selectRow(indexOfStart, inComponent: 0, animated: true)
                    }
                    if let indexOfEnd = PickerData.startEndArr.index(of: String(measurement.end.split(separator: "_")[1])) {
                        end.selectRow(indexOfEnd, inComponent: 0, animated: true)
                    }
                } else {
                    hide()
                }
            }
        }
    }
    
    private func hide() {
        start.isHidden = true
        end.isHidden = true
    }
    
    private func show() {
        start.isHidden = false
        end.isHidden = false
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
    
    @IBAction func onOnlineOrHistoricalChange(_ sender: UISegmentedControl) {
        measurement?.mode = sender.selectedSegmentIndex
        if measurement?.mode == Measurement.HIST {
            show()
        } else {
            hide()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView === start {
            measurement?.start = PickerData.NAMED+PickerData.startEndArr[row]
        } else if pickerView === end {
            measurement?.end = PickerData.NAMED+PickerData.startEndArr[row]
        }
    }
    
    @IBAction func onFavoriteChange(_ sender: UISwitch) {
        measurement?.favorite = sender.isOn
    }
    
    @IBAction func onWatchTilteChanged(_ sender: UITextField) {
        measurement?.watchTitle = sender.text ?? ""
    }
    
    @IBAction func onUnitChanged(_ sender: UITextField) {
        measurement?.unit2 = sender.text ?? ""
    }
    
    
    @IBAction func onSaveClick(_ sender: UIButton) {
        if let unarchivedObject = UserDefaults.standard.data(forKey: Measurement.KEY_FOR_USER_DEFAULTS) {
            
            if !savedData.contains(where: { (m: Measurement) -> Bool in return m == measurement!}) {
                savedData.append(measurement!)
            } else if let m = measurement, let idx = m.index {
                savedData[idx] = m
            }
            
            //SAVE
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: savedData, requiringSecureCoding: false)
                
                UserDefaults.standard.set(data, forKey: Measurement.KEY_FOR_USER_DEFAULTS)
            } catch {
                fatalError("Can't encode data: \(error)")
            }
            
        }
    }
}
