//
//  MeasurementDetailViewController.swift
//  JanOnVal
//
//  Created by Andreas Müller on 15.02.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import UIKit

class MeasurementDetailViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    var measurement: Measurement?
    
    @IBOutlet weak var valueName: UILabel!
    @IBOutlet weak var typeName: UILabel!
    
    @IBOutlet weak var watchTitle: UITextField!
    @IBOutlet weak var isOnlineOrHistorrical: UISegmentedControl!
    
    
    @IBOutlet weak var startLbl: UILabel!
    @IBOutlet weak var endLbl: UILabel!
    
    @IBOutlet weak var start: UIButton!    
    @IBOutlet weak var end: UIButton!
    
    private var startIdx = 0
    private var endIdx = 0
    
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
                } else {
                    hide()
                }
                
                if let indexOfStart = PickerData.startEndArr.firstIndex(of: String(measurement.start.split(separator: "_")[1])) {
                    startIdx = indexOfStart
                    start.setTitle(PickerData.startEndArr[startIdx], for: UIControl.State.normal)
                }
                if let indexOfEnd = PickerData.startEndArr.firstIndex(of: String(measurement.end.split(separator: "_")[1])) {
                    endIdx = indexOfEnd
                    end.setTitle(PickerData.startEndArr[endIdx], for: UIControl.State.normal)
                }
                start.menu = addMenuItemsForStart(start, true)
                end.menu = addMenuItemsForStart(end, false)
            }
        }
    }
    
    func addMenuItemsForStart(_ button: UIButton, _ isStart: Bool) -> UIMenu {
        let menuItems = UIMenu(title: "START", children: [
            UIAction(title: NSLocalizedString(PickerData.startEndArr[0], comment: "")) { action in
                button.setTitle(PickerData.startEndArr[0], for: UIControl.State.normal)
                if isStart {
                    self.startIdx = 0
                    self.measurement?.start = PickerData.NAMED+PickerData.startEndArr[self.startIdx]
                } else {
                    self.endIdx = 0
                    self.measurement?.end = PickerData.NAMED+PickerData.startEndArr[self.endIdx]
                }
                
            },
            UIAction(title: NSLocalizedString(PickerData.startEndArr[1], comment: "")) { action in
                button.setTitle(PickerData.startEndArr[1], for: UIControl.State.normal)
                if isStart {
                    self.startIdx = 1
                    self.measurement?.start = PickerData.NAMED+PickerData.startEndArr[self.startIdx]
                } else {
                    self.endIdx = 1
                    self.measurement?.end = PickerData.NAMED+PickerData.startEndArr[self.endIdx]
                }
            },
            UIAction(title: NSLocalizedString(PickerData.startEndArr[2], comment: "")) { action in
                button.setTitle(PickerData.startEndArr[2], for: UIControl.State.normal)
                if isStart {
                    self.startIdx = 2
                    self.measurement?.start = PickerData.NAMED+PickerData.startEndArr[self.startIdx]
                } else {
                    self.endIdx = 2
                    self.measurement?.end = PickerData.NAMED+PickerData.startEndArr[self.endIdx]
                }
            },
            UIAction(title: NSLocalizedString(PickerData.startEndArr[3], comment: "")) { action in
                button.setTitle(PickerData.startEndArr[3], for: UIControl.State.normal)
                if isStart {
                    self.startIdx = 3
                    self.measurement?.start = PickerData.NAMED+PickerData.startEndArr[self.startIdx]
                } else {
                    self.endIdx = 3
                    self.measurement?.end = PickerData.NAMED+PickerData.startEndArr[self.endIdx]
                }
            },
            UIAction(title: NSLocalizedString(PickerData.startEndArr[4], comment: "")) { action in
                button.setTitle(PickerData.startEndArr[4], for: UIControl.State.normal)
                if isStart {
                    self.startIdx = 4
                    self.measurement?.start = PickerData.NAMED+PickerData.startEndArr[self.startIdx]
                } else {
                    self.endIdx = 4
                    self.measurement?.end = PickerData.NAMED+PickerData.startEndArr[self.endIdx]
                }
            },
            UIAction(title: NSLocalizedString(PickerData.startEndArr[5], comment: "")) { action in
                button.setTitle(PickerData.startEndArr[5], for: UIControl.State.normal)
                if isStart {
                    self.startIdx = 5
                    self.measurement?.start = PickerData.NAMED+PickerData.startEndArr[self.startIdx]
                } else {
                    self.endIdx = 5
                    self.measurement?.end = PickerData.NAMED+PickerData.startEndArr[self.endIdx]
                }
            },
            UIAction(title: NSLocalizedString(PickerData.startEndArr[6], comment: "")) { action in
                button.setTitle(PickerData.startEndArr[6], for: UIControl.State.normal)
                if isStart {
                    self.startIdx = 6
                    self.measurement?.start = PickerData.NAMED+PickerData.startEndArr[self.startIdx]
                } else {
                    self.endIdx = 6
                    self.measurement?.end = PickerData.NAMED+PickerData.startEndArr[self.endIdx]
                }
            },
            UIAction(title: NSLocalizedString(PickerData.startEndArr[7], comment: "")) { action in
                button.setTitle(PickerData.startEndArr[7], for: UIControl.State.normal)
                if isStart {
                    self.startIdx = 7
                    self.measurement?.start = PickerData.NAMED+PickerData.startEndArr[self.startIdx]
                } else {
                    self.endIdx = 7
                    self.measurement?.end = PickerData.NAMED+PickerData.startEndArr[self.endIdx]
                }
            }
        ] )
        
        return menuItems
    }
      
    private func hide() {
        startLbl.isHidden = true
        endLbl.isHidden = true
        start.isHidden = true
        end.isHidden = true
    }
    
    private func show() {
        start.isHidden = false
        end.isHidden = false
        startLbl.isHidden = false
        endLbl.isHidden = false
    }
    
    @IBAction func onOnlineOrHistoricalChange(_ sender: UISegmentedControl) {
        measurement?.mode = sender.selectedSegmentIndex
        if measurement?.mode == Measurement.HIST {
            show()
        } else {
            hide()
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
                if let sharedUD = UserDefaults(suiteName: "group.measurements") {
                    do {
                        let data = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! [Measurement]
                        let defaults = UserDefaults.standard
                        let HOST = "HOST"
                        let PORT = "PORT"
                        let PROJECT = "PROJECT"
                        
                        /*.filter({ (measurement) -> Bool in
                         return measurement.valueType?.value.contains("ActiveEnergy") ?? false || measurement.valueType?.value.contains("Power") ?? false
                         })
                         */
                        let arr = data.map { measurement -> [String: String] in
                            var d: [String: String] = [:]
                            d["measurementType"] = measurement.valueType!.type
                            d["measurementValue"] = measurement.valueType!.value
                            d["deviceId"] = String(measurement.device!.id)
                            d[PROJECT] = defaults.string(forKey: PROJECT)
                            d[PORT] = defaults.string(forKey: PORT)
                            d[HOST] = defaults.string(forKey: HOST)
                            d["title"] = measurement.watchTitle
                            d["deviceName"] = measurement.device!.name
                            d["unit2"] = measurement.unit2
                            d["unit"] = measurement.valueType!.unit
                            
                            return d
                        }
                        
                        sharedUD.set(arr, forKey: Measurement.KEY_FOR_USER_DEFAULTS)
                    } catch {
                        fatalError("IntentHandler - Can't encode data: \(error)")
                    }
                } else {
                    print("App group failed")
                }
            } catch {
                fatalError("Can't encode data: \(error)")
            }
            
        }
    }
}
