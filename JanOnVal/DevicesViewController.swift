//
//  DevicesViewController.swift
//  JanOnVal
//
//  Created by Andreas Mueller on 26.01.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import UIKit

class DevicesViewController: UITableViewController {
    
    // MARK: devices properties
    
    var appModel: AppModel?
    
    var deviceArr = [Device]()
    var fetchDevicesTask: URLSessionDataTask?
    var serverUrlOrig = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tbc = tabBarController as? AppTabBarController
        appModel = tbc?.appModel
        print("didLoad \(appModel!.serverUrl)")
        serverUrlOrig = appModel!.serverUrl
        
        fetchDevicesTask = createFetchTask()
        fetchDevicesTask?.resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("willAppear \(appModel!.serverUrl)")
        if serverUrlOrig != appModel!.serverUrl {
            fetchDevicesTask = createFetchTask()
            fetchDevicesTask?.resume()
            serverUrlOrig = appModel!.serverUrl
            print("fetching devices")
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceArr.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath)
        
        // Configure the cell...
        let device = deviceArr[indexPath.row]
        cell.textLabel?.text = device.name
        cell.detailTextLabel?.text = device.description
        
        if appModel!.selectedDeviceArr.contains(device) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let device = deviceArr[indexPath.row]
        
        cell?.accessoryType = .checkmark
        appModel!.selectedDeviceArr.append(device)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let device = deviceArr[indexPath.row]
        cell?.accessoryType = .none
        appModel!.selectedDeviceArr.remove(at:appModel!.selectedDeviceArr.index(of: device)!)
    }
    
    fileprivate func showAlert(alertTitle title: String, alertMessage message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        //TODO: go back to server config in handler
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    fileprivate func createFetchTask() -> URLSessionDataTask {
        deviceArr = []
        
        var request = URLRequest(url: URL(string:"\(appModel!.serverUrl)devices")!)
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let session = URLSession.shared
        return session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            
            do {
                if let devicesData = data {
                    //print(String(data: data!,encoding: String.Encoding.utf8) as! String)
                    let json = try JSONSerialization.jsonObject(with: devicesData, options: []) //as! Dictionary<String, AnyObject>
                    
                    
                    let deviceArr = ((json as? [String: Any])!["device"] as? [[String: Any]])!;
                    for device in deviceArr {
                        let d = Device(json: device);
                        self.deviceArr.append(d!)
                    }
                    
                    //sort
                    self.deviceArr.sort(by: {$0.name < $1.name})
                    
                    DispatchQueue.main.async { // Correct
                        self.tableView.reloadData()
                    }
                } else {
                    self.showAlert(
                        alertTitle: "No devices found.",
                        alertMessage: "Check your server config!"
                    )
                }
            } catch {
                print("error:\(error)")
                self.showAlert(
                    alertTitle: "Something went wrong :(",
                    alertMessage: "Check your server config!"
                )
                DispatchQueue.main.async { // Correct
                    self.tableView.reloadData()
                }
            }
        })
    }
    
}
