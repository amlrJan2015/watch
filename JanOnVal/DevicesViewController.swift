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
    
    var devices :[Device] = []
//    let selectedDevices = (UIApplication.shared.delegate as? AppDelegate)!.appModel.selectedDeviceSet
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
//        print("\((UIApplication.shared.delegate as? AppDelegate)!.appModel.serverUrl)devices")
        
        var request = URLRequest(url: URL(string:"\((UIApplication.shared.delegate as? AppDelegate)!.appModel.serverUrl)devices")!)
        //var request = URLRequest(url: URL(string:"\((UIApplication.shared.delegate as? AppDelegate)!.appModel.serverUrl)onlinevalues?value=1;Temperature;Temp_Extern1")!)
        
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
            (UIApplication.shared.delegate as? AppDelegate)!.appModel.selectedDeviceSet.remove(device)
        } else {
            cell?.accessoryType = .checkmark
            (UIApplication.shared.delegate as? AppDelegate)!.appModel.selectedDeviceSet.insert(device)
        }
//        print(selectedDevices)
//        print((UIApplication.shared.delegate as? AppDelegate)!.appModel.selectedDeviceSet)
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
