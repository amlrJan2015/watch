//
//  MeasurementTableViewController.swift
//  JanOnVal
//
//  Created by Andreas Mueller on 28.01.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import UIKit

class MeasurementTableViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    var appModel: AppModel?
    var measurements = Dictionary<Device, [Measurement]>()
    var currMeasurements = Dictionary<Device, [Measurement]>()
    var selectedMeasurement = Dictionary<Device, [Measurement]>()
    var selectedDeviceArrOrig = [Device]()
    
    @IBOutlet var gesture: UISwipeGestureRecognizer!
    @IBAction func swipeDown(_ sender: UISwipeGestureRecognizer) {
        self.view.endEditing(true)
    }
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var measurementSearchBar: UISearchBar!
    
    fileprivate func fetchDataForSelectedDevices() {
        for device in appModel!.selectedDeviceArr {
            
            measurements[device] = []
            currMeasurements[device] = []
            selectedMeasurement[device] = []
            
            var request = URLRequest(url: URL(string:"\(appModel!.serverUrl)devices/\(device.id)/hist/values")!)
            
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            let session = URLSession.shared
            let fetchDevicesTask = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                if let measurementsData = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: measurementsData, options: []) //as! Dictionary<String, AnyObject>
                        
                        let measurementArr = ((json as? [String: Any])!["value"] as? [[String: Any]])!;
                        DispatchQueue.main.async { // Correct
                            for measurement in measurementArr {
                                let m = Measurement(json: measurement);
                                m?.device = device
                                
                                self.measurements[device]?.append(m!)
                                if let measurement = m,
                                    let valueType = measurement.valueType {
                                    if self.measurementSearchBar.scopeButtonTitles![self.measurementSearchBar.selectedScopeButtonIndex] == valueType.value {
                                        self.currMeasurements[device]?.append(m!)
                                    }
                                }
                            }
                            
                            self.tableView.reloadData()
                        }
                    } catch {
                        print("error:\(error)")
                    }
                } else {
                    print("No data to:\(self.appModel!.serverUrl)devices/\(device.id)/online/values)")
                }
                
            })
            
            fetchDevicesTask.resume()
        }
        
        if appModel!.selectedDeviceArr.count == 0 {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.connectivityHandler = (UIApplication.shared.delegate as? AppDelegate)?.connectivityHandler
        let tbc = tabBarController as? AppTabBarController
        appModel = tbc?.appModel
        
        selectedDeviceArrOrig = appModel!.selectedDeviceArr
        
        fetchDataForSelectedDevices()
        
        //delegates
        self.measurementSearchBar.delegate = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.gesture.delegate = self
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if selectedDeviceArrOrig != appModel!.selectedDeviceArr {
            selectedDeviceArrOrig = appModel!.selectedDeviceArr
            print("fetching measurement")
            fetchDataForSelectedDevices()
        }
        
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - SearchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currMeasurements = [:]
        let selectedScope = searchBar.selectedScopeButtonIndex
        for (device, measurementArr) in measurements {
            currMeasurements[device] = [Measurement]()
            for measurement in measurementArr {
                if let valueType = measurement.valueType {
                    if "" == searchText {
                        if  "No Filter" == searchBar.scopeButtonTitles![selectedScope] ||
                            searchBar.scopeButtonTitles![selectedScope] == valueType.value {
                            currMeasurements[device]!.append(measurement)
                        }
                    } else if valueType.valueName.localizedCaseInsensitiveContains(searchText) {
                        currMeasurements[device]!.append(measurement)
                    }
                }
            }
        }
        
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        currMeasurements = [:]
        
        for (device, measurementArr) in measurements {
            currMeasurements[device] = [Measurement]()
            if "No Filter" == measurementSearchBar.scopeButtonTitles![selectedScope] {
                currMeasurements[device] = measurementArr
            } else {
                for measurement in measurementArr {
                    if let valueType = measurement.valueType {
                        if measurementSearchBar.scopeButtonTitles![selectedScope] == valueType.value {
                            currMeasurements[device]!.append(measurement)
                        }
                    }
                }
            }
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return appModel!.selectedDeviceArr.count;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currMeasurements.count > 0 {
            let device = appModel!.selectedDeviceArr[section]
            return currMeasurements[device]!.count
        }
        
        return 0
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
        let device = appModel!.selectedDeviceArr[indexPath.section]
        let measurement = currMeasurements[device]![indexPath.row]
        cell.textLabel?.text = measurement.valueType?.valueName ?? ""
        cell.detailTextLabel?.text = measurement.valueType?.typeName ?? ""
        
        //        if selectedMeasurement[device]!.contains(measurement){
        //            cell.accessoryType = .checkmark
        //        } else {
        //            cell.accessoryType = .none
        //        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let device = appModel!.selectedDeviceArr[indexPath.section]
        let measurement = currMeasurements[device]![indexPath.row]
        
        if selectedMeasurement[device]!.contains(measurement){
            //            cell?.accessoryType = .none
            let idxToRemove = selectedMeasurement[device]?.firstIndex(of: measurement)
            selectedMeasurement[device]?.remove(at: idxToRemove!)
        } else {
            //            cell?.accessoryType = .checkmark
            selectedMeasurement[device]!.append(measurement)
        }
        
        self.view.endEditing(true);
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "ShowMeasurementDetail" {
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
            
            let device = appModel!.selectedDeviceArr[indexPath.section]
            let measurement = currMeasurements[device]![indexPath.row]
            var mArr = selectedMeasurement[measurement.device!]!
            if let mIdx = mArr.firstIndex(of: measurement) {
                detailVC.measurement = mArr[mIdx]
            } else {
                detailVC.measurement = measurement
            }
        }
    }
}
