//
//  DevicesViewController.swift
//  JanOnVal
//
//  Created by Christian Stolz on 26.01.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import UIKit

class DevicesViewController: UITableViewController {
    
    // MARK: devices properties
    
    var appModel: AppModel?
    
    var devices :[Device] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tbc = tabBarController as? AppTabBarController
        appModel = tbc?.appModel
        
        var request = URLRequest(url: URL(string:"\(appModel!.serverUrl)devices")!)
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let session = URLSession.shared
        let fetchDevicesTask = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            
            do {
                if let devicesData = data {
                    //print(String(data: data!,encoding: String.Encoding.utf8) as! String)
                    let json = try JSONSerialization.jsonObject(with: devicesData, options: []) //as! Dictionary<String, AnyObject>
                    
                    
                    let deviceArr = ((json as? [String: Any])!["device"] as? [[String: Any]])!;
                    for device in deviceArr {
                        let d = Device(json: device);
                        self.devices.append(d!)
                    }
                    DispatchQueue.main.async { // Correct
                        self.tableView.reloadData()
                    }
                } else {
                    let alert = UIAlertController(
                        title: "No devices found.",
                        message: "Check your server config!",
                        preferredStyle: .alert
                    )
                    //TODO: go back to server config in handler
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            } catch {
                print("error:\(error)")
            }
            
        })
        
        fetchDevicesTask.resume()
        
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath)
        
        // Configure the cell...
        let device = devices[indexPath.row]
        cell.textLabel?.text = device.name
        cell.detailTextLabel?.text = device.description
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let device = devices[indexPath.row]
        
        if appModel!.selectedDeviceArr.contains(device) {
            cell?.accessoryType = .none
            appModel!.selectedDeviceArr.remove(at:appModel!.selectedDeviceArr.index(of: device)!)
        } else {
            cell?.accessoryType = .checkmark
            appModel!.selectedDeviceArr.append(device)
        }
        print(appModel!.selectedDeviceArr)
    }
    
}
