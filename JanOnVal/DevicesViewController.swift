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
        
        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        var request = URLRequest(url: URL(string:"\(appModel!.serverUrl)devices")!)
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let session = URLSession.shared
        let fetchDevicesTask = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            
            do {
                //print(String(data: data!,encoding: String.Encoding.utf8) as! String)
                let json = try JSONSerialization.jsonObject(with: data!, options: []) //as! Dictionary<String, AnyObject>
                
                
                let deviceArr = ((json as? [String: Any])!["device"] as? [[String: Any]])!;
                for device in deviceArr {
                    let d = Device(json: device);
                    //                    print("name:\((d?.name)!)")
                    self.devices.append(d!)
                }
                DispatchQueue.main.async { // Correct
                    self.tableView.reloadData()
                }
            } catch {
                print("error:\(error)")
            }
            
        })
        
        fetchDevicesTask.resume()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if cell?.accessoryType == .checkmark {
            cell?.accessoryType = .none
            appModel!.selectedDeviceArr.remove(at: indexPath.row)
        } else {
            cell?.accessoryType = .checkmark
            appModel!.selectedDeviceArr.insert(device, at: indexPath.row)
        }
        print(appModel!.selectedDeviceArr)
    }
    
}
