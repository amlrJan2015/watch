//
//  MeasurementTableViewController.swift
//  JanOnVal
//
//  Created by Christian Stolz on 28.01.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import UIKit

class MeasurementTableViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var connectivityHandler: ConnectivityHandler!
    
    var appModel: AppModel?
    
    var measurements: [Measurement] = []
    var currMeasurements: [Measurement] = []
    var selectedMeasurement = Dictionary<String, String>()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var measurementSearchBar: UISearchBar!
    
    @IBAction func sendMeasurementsToWatch(_ sender: UIButton) {
        connectivityHandler.session.sendMessage(
            [
                "serverUrl": appModel?.serverUrl,
                "selectedMeasurementArr": Array(selectedMeasurement.values)
        ], replyHandler: nil) { (err) in
            NSLog("%@", "Error sending data to watch: \(err)")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.connectivityHandler = (UIApplication.shared.delegate as? AppDelegate)?.connectivityHandler
        let tbc = tabBarController as? AppTabBarController
        appModel = tbc?.appModel
        
        print(appModel!.selectedDeviceArr)
        
        for device in appModel!.selectedDeviceArr {
            
            var request = URLRequest(url: URL(string:"\(appModel!.serverUrl)devices/\(device.id)/online/values")!)
            
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            let session = URLSession.shared
            let fetchDevicesTask = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                
                do {
                    //                    print(String(data: data!,encoding: String.Encoding.utf8) as! String)
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) //as! Dictionary<String, AnyObject>
                    
                    let measurementArr = ((json as? [String: Any])!["valuetype"] as? [[String: Any]])!;
                    DispatchQueue.main.async { // Correct
                        for measurement in measurementArr {
                            let m = Measurement(json: measurement);
                            self.measurements.append(m!)
                            if self.measurementSearchBar.scopeButtonTitles![self.measurementSearchBar.selectedScopeButtonIndex] == m?.value {
                                self.currMeasurements.append(m!)
                            }
                        }
                        
                        self.tableView.reloadData()
                    }
                } catch {
                    print("error:\(error)")
                }
                
            })
            
            fetchDevicesTask.resume()
        }
        self.measurementSearchBar.delegate = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - SearchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchText.count > 0 {
//            searchBar.showsScopeBar = false
//        } else {
//            searchBar.showsScopeBar = true
//        }
        
        currMeasurements = []
        for measurement in measurements {
            if  measurement.valueName.contains(searchText) {
                currMeasurements.append(measurement)
            }
        }
        
        self.tableView.reloadData()        
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        currMeasurements = []
        
        for measurement in measurements {
            if "No Filter" == measurementSearchBar.scopeButtonTitles![selectedScope] {
                currMeasurements.append(measurement)
            } else if measurementSearchBar.scopeButtonTitles![selectedScope] == measurement.value {
                currMeasurements.append(measurement)
            }
        }
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return appModel!.selectedDeviceArr.count;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currMeasurements.count
    }
 
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return appModel?.selectedDeviceArr[section].name
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let vw = UIView()
//        vw.backgroundColor = UIColor.blue
//
//        return vw
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeasurementCell", for: indexPath)
        
        // Configure the cell...
        let measurement = currMeasurements[indexPath.row]
        cell.textLabel?.text = measurement.valueName
        cell.detailTextLabel?.text = measurement.typeName
        let key = "\(indexPath.section);\(measurement.value);\(measurement.type)"
        if selectedMeasurement[key] != nil {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let measurement = currMeasurements[indexPath.row]
        let key = "\(indexPath.section);\(measurement.value);\(measurement.type)"

        if selectedMeasurement[key] != nil {
            cell?.accessoryType = .none
            selectedMeasurement.removeValue(forKey: key)
        } else {
            cell?.accessoryType = .checkmark
//            onlinevalues?value=1;PowerActive;SUM13
            let device = appModel?.selectedDeviceArr[indexPath.section]
            selectedMeasurement[key] = "\(device!.id);\(measurement.value);\(measurement.type);\(measurement.unit)"
        }
    }
}
