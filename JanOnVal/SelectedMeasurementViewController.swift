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
    
    //var data:[Measurement] = []
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
                appModel?.data = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(unarchivedObject) as! [Measurement]
                tableView.reloadData()
                /* \(UserDefaults.standard.string(forKey: "lastReceiveRemoteNotificationData") ?? "")*/
                sendButton.setTitle("Send To Watch", for: .normal)
            } catch {
                fatalError("loadWidgetDataArray - Can't encode data: \(error)")
            }
        }
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
                "measurementDataDictArr": appModel?.getMeasurementData() ?? [],
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
        return appModel?.data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectedMeasurementCell", for: indexPath)
        if let measurement = appModel?.data[indexPath.row] {
            cell.textLabel?.text = "\(measurement.watchTitle) \(measurement.valueType?.typeName ?? "") \(measurement.valueType?.valueName ?? "") \(measurement.favorite ? "⭐️" : "")"
            cell.detailTextLabel?.text = "\(measurement.device?.name ?? "") [\(measurement.device?.desc ?? "")]"
            if (indexPath.row >= SelectedMeasurementViewController.MAX_VALUES_COUNT) {
                cell.backgroundColor = UIColor.red
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexpath) in
            self.appModel?.data.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .left)
            self.saveData()
        }
        deleteAction.backgroundColor = .red
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let itemToMove = appModel?.data[sourceIndexPath.row] {
            appModel?.data.remove(at: sourceIndexPath.row)
            appModel?.data.insert(itemToMove, at: destinationIndexPath.row)
        }
        
        saveData()
        
        tableView.reloadData()
    }
    
    func saveData() {
        //SAVE
        do {
            let newData = try NSKeyedArchiver.archivedData(withRootObject: appModel?.data, requiringSecureCoding: false)
            
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
            
            if let measurement = appModel?.data[indexPath.row] {
                measurement.index = appModel?.data.firstIndex(of: measurement)
                measurement.selected = true
                
                detailVC.measurement = measurement
            }
        }
    }
    
    @IBAction func onClickShowValues(_ sender: UIButton) {
        do {
            let data = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(UserDefaults.standard.data(forKey: Measurement.KEY_FOR_USER_DEFAULTS)!) as! [Measurement]
            let vc = UIHostingController(rootView: ValuesScreen(configData: appModel?.data ?? [], viewModel: MeasurementValueViewModel(serverUrl: appModel!.serverUrl, refreshTime: appModel!.refreshTime, measurementData: appModel?.getMeasurementData() ?? [])))
            present(vc, animated: true)
        } catch {
            fatalError("Can't encode selected data: \(error)")
        }
    }
    
}
