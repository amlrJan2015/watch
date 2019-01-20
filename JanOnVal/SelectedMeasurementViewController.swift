//
//  SelectedMeasurementViewController.swift
//  JanOnVal
//
//  Created by Andreas Müller on 02.01.19.
//  Copyright © 2019 Andreas Mueller. All rights reserved.
//

import UIKit

class SelectedMeasurementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var data:[Measurement] = []
    var connectivityHandler: ConnectivityHandler!
    var appModel: AppModel?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func onSendToWatchClick(_ sender: UIButton) {
        var dictArr = [[String:Any]]()
        for measurement in data {
            
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
        
        connectivityHandler.session.sendMessage(
            [
                "serverUrl": appModel!.serverUrl,
                "measurementDataDictArr": dictArr,
                "refreshTime": appModel!.refreshTime
        ], replyHandler: nil) { (err) in
            NSLog("%@", "Error sending data to watch: \(err)")
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
    
    //    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    //        return UITableViewCell.EditingStyle.none
    //    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        let temp = data[destinationIndexPath.row]
//        data[destinationIndexPath.row] = data[sourceIndexPath.row]
//        data[sourceIndexPath.row] = temp
        
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
            } catch {
                fatalError("loadWidgetDataArray - Can't encode data: \(error)")
            }
        }
    }
    
    //    func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
    //        let action = UIContextualAction(style: .destructive,
    //                                        title: "Delete") {
    //                                            (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
    //
    //                                            print("Deleting")
    //                                            self.data.remove(at: indexPath.row)
    //                                            self.tableView.deleteRows(at: [indexPath], with: .left)
    //                                            completionHandler(true)
    //        }
    //
    //        return action
    //    }
    
    //    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    //        let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
    //        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
    //        return swipeConfig
    //    }
    
    //    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    //        let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
    //        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
    //        return swipeConfig
    //    }
    
}
