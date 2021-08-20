//
//  SelectedMeasurementViewController.swift
//  JanOnVal
//
//  Created by Andreas Müller on 02.01.19.
//  Copyright © 2019 Andreas Mueller. All rights reserved.
//

import UIKit

class SelectedMeasurementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    public static let MAX_VALUES_COUNT = 30
    
    var data:[Measurement] = []
    var connectivityHandler: ConnectivityHandler!
    var appModel: AppModel?
    
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
                sendButton.setTitle("Send To Watch \(UserDefaults.standard.string(forKey: "lastReceiveRemoteNotificationData") ?? "")", for: .normal)
            } catch {
                fatalError("loadWidgetDataArray - Can't encode data: \(error)")
            }
        }
    }
    
    @IBAction func onSendToWatchClick(_ sender: UIButton) {
        var dictArr = [[String:Any]]()
        var index = 0
        for measurement in data {
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
            index = index + 1
        }
        
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
                "measurementDataDictArr": dictArr,
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
}
