//
//  SelectedMeasurementViewController.swift
//  JanOnVal
//
//  Created by Andreas Müller on 02.01.19.
//  Copyright © 2019 Andreas Mueller. All rights reserved.
//

import UIKit
import SwiftUI
//import CloudKit

class SelectedMeasurementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    public static let MAX_VALUES_COUNT = 30
    
    var data:[Measurement] = []
    var connectivityHandler: ConnectivityHandler!
    var appModel: AppModel?

    //private let defaultContainer = CKContainer.default()
    //private lazy var database = defaultContainer.privateCloudDatabase
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sendButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.connectivityHandler = (UIApplication.shared.delegate as? AppDelegate)?.connectivityHandler
        let tbc = tabBarController as? AppTabBarController
        appModel = tbc?.appModel
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.setEditing(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let unarchivedObject = UserDefaults.standard.data(forKey: Measurement.KEY_FOR_USER_DEFAULTS) {
            do {
                data = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(unarchivedObject) as! [Measurement]
                tableView.reloadData()
                /* \(UserDefaults.standard.string(forKey: "lastReceiveRemoteNotificationData") ?? "")*/
                sendButton.setTitle("Send To Watch", for: .normal)
            } catch {
                fatalError("loadWidgetDataArray - Can't encode data: \(error)")
            }
        }
    }
    
    func getMeasurementData() -> [[String:Any]] {
        var dictArr = [[String:Any]]()
        //var recordsToSave: [CKRecord] = []
        
        for (index, measurement) in data.enumerated() {
            
            /*let measurementValueRecord = CKRecord(recordType: "MeasurementValue", recordID: CKRecord.ID(recordName: "measurementValue\(index)"))
            measurementValueRecord["deviceId"] = measurement.device?.id
            measurementValueRecord["deviceName"] = measurement.device?.name
            measurementValueRecord["start"] = measurement.start
            measurementValueRecord["end"] = measurement.end
            measurementValueRecord["favorite"] = String(measurement.favorite)
            measurementValueRecord["index"] = index
            measurementValueRecord["isOnline"] = String(measurement.online)
            measurementValueRecord["measurementType"] = measurement.valueType?.type ?? ""
            measurementValueRecord["measurementTypeName"] = measurement.valueType?.typeName ?? ""
            measurementValueRecord["measurementValue"] = measurement.valueType?.value ?? ""
            measurementValueRecord["measurementValueName"] = measurement.valueType?.valueName ?? ""
            measurementValueRecord["mode"] = measurement.mode
            measurementValueRecord["timebase"] = String(measurement.timebase)
            measurementValueRecord["unit"] = measurement.valueType?.unit ?? ""
            measurementValueRecord["unit2"] = measurement.unit2
            measurementValueRecord["watchTitle"] = measurement.watchTitle*/
            
            
            //recordsToSave.append(measurementValueRecord)
            
            if index < SelectedMeasurementViewController.MAX_VALUES_COUNT {
                dictArr.append([
                    "watchTitle":measurement.watchTitle,
                    "isOnline": measurement.online,
                    "start": measurement.start,
                    "end": measurement.end,
                    "unit": "\(measurement.valueType?.unit ?? "")",
                    "unit2": "\(measurement.unit2)",
                    "deviceId" : measurement.device?.id,
                    "deviceName" : measurement.device?.name,
                    "mode": measurement.mode,
                    "timebase": String(measurement.timebase),
                    "measurementValue": measurement.valueType?.value ?? "",
                    "measurementValueName": measurement.valueType?.valueName ?? "",
                    "measurementType": measurement.valueType?.type ?? "",
                    "measurementTypeName": measurement.valueType?.typeName ?? "",
                    MeasurementPropertyKey.favorite: measurement.favorite
                ])
            }
        }
        
        /*database.fetch(withRecordID: CKRecord.ID(recordName: "config")) { recordOpt, error in
            if error != nil {
                print("Error:\(error)")
            }
            
            if let configRecord = recordOpt {
                recordsToSave.forEach { record in
                    record["config"] = CKRecord.Reference(record: configRecord, action: CKRecord.ReferenceAction.deleteSelf)
                }
                
                //TODO: save confgiMVs changes
                
                self.database.modifyRecords(saving: recordsToSave, deleting: [], savePolicy: CKModifyRecordsOperation.RecordSavePolicy.allKeys, atomically: true) { result in
                    switch result {
                    case .success(let successInfo):
                        print("Save measurements to Cloud SUCCESS[\(successInfo.saveResults.count)]")
                        break
                    case .failure(let error):
                        print(error)
                    }
                }                
            }
        }*/
        
        return dictArr
    }
    
    @IBAction func onSendToWatchClick(_ sender: UIButton) {
        
        
        //        connectivityHandler.session.sendMessage(
        //            [
        //                "serverUrl": appModel!.serverUrl,
        //                "measurementDataDictArr": dictArr,
        //                "refreshTime": appModel!.refreshTime
        //        ], replyHandler: nil) { (err) in
        //            NSLog("%@", "Error sending data to watch: \(err)")
        //        }
        if connectivityHandler !== nil && connectivityHandler.session.activationState == .activated {
            connectivityHandler.session.transferUserInfo([
                "serverUrl": appModel!.serverUrl,
                "measurementDataDictArr": getMeasurementData(),
                "refreshTime": appModel!.refreshTime])
        } else {
            showAlert(alertTitle: "Failed to transfer config", alertMessage: "Start Watch App oder iPad?")
        }
        
        //                }
    }
    
    fileprivate func showAlert(alertTitle title: String, alertMessage message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        //TODO: go back to server config in handler
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectedMeasurementCell", for: indexPath)
        let measurement = data[indexPath.row]
        cell.textLabel?.text = "\(measurement.watchTitle) \(measurement.valueType?.typeName ?? "") \(measurement.valueType?.valueName ?? "") \(measurement.favorite ? "⭐️" : "")"
        cell.detailTextLabel?.text = "\(measurement.device?.name ?? "") [\(measurement.device?.desc ?? "")]"
        if (indexPath.row >= SelectedMeasurementViewController.MAX_VALUES_COUNT) {
            cell.backgroundColor = UIColor.red
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexpath) in
            self.data.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .left)
            self.saveData()
        }
        deleteAction.backgroundColor = .red
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = data[sourceIndexPath.row]
        data.remove(at: sourceIndexPath.row)
        data.insert(itemToMove, at: destinationIndexPath.row)
        
        saveData()
        
        tableView.reloadData()
    }
    
    func saveData() {
        //SAVE
        do {
            let newData = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
            
            UserDefaults.standard.set(newData, forKey: Measurement.KEY_FOR_USER_DEFAULTS)
        } catch {
            fatalError("Can't encode data: \(error)")
        }
    }
    
    
    // MARK: - prepare for segue
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "EditMeasurement" {
            guard let detailVC = segue.destination as? MeasurementDetailViewController
            else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedMeasurementCell = sender as? UITableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            guard let indexPath = tableView.indexPath(for: selectedMeasurementCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let measurement = data[indexPath.row]
            measurement.index = data.firstIndex(of: measurement)
            measurement.selected = true
            
            detailVC.measurement = measurement
        }
    }
    
    @IBAction func onClickShowValues(_ sender: UIButton) {
        do {
            let data = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(UserDefaults.standard.data(forKey: Measurement.KEY_FOR_USER_DEFAULTS)!) as! [Measurement]
            let vc = UIHostingController(rootView: ValuesScreen(configData: data, viewModel: MeasurementValueViewModel(serverUrl: appModel!.serverUrl, refreshTime: appModel!.refreshTime, measurementData: getMeasurementData())))
            present(vc, animated: true)
        } catch {
            fatalError("Can't encode selected data: \(error)")
        }
    }
    
}
