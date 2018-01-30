//
//  MeasurementTableViewController.swift
//  JanOnVal
//
//  Created by Christian Stolz on 28.01.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import UIKit

class MeasurementTableViewController: UITableViewController, UISearchBarDelegate {
    
//    let selectedDevices =
//    let serverUrl =
    
    var measurements: [Measurement] = []
    var currMeasurements: [Measurement] = []

    @IBOutlet weak var measurementSearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print((UIApplication.shared.delegate as? AppDelegate)!.appModel.selectedDeviceSet)
        
        for device in (UIApplication.shared.delegate as? AppDelegate)!.appModel.selectedDeviceSet {
            
            var request = URLRequest(url: URL(string:"\((UIApplication.shared.delegate as? AppDelegate)!.appModel.serverUrl)devices/\(device.id)/online/values")!)
            //var request = URLRequest(url: URL(string:"\((UIApplication.shared.delegate as? AppDelegate)!.appModel.serverUrl)onlinevalues?value=1;Temperature;Temp_Extern1")!)
            
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            let session = URLSession.shared
            let fetchDevicesTask = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                
                do {
//                    print(String(data: data!,encoding: String.Encoding.utf8) as! String)
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) //as! Dictionary<String, AnyObject>
                    
                    let measurementArr = ((json as? [String: Any])!["valuetype"] as? [[String: Any]])!;
                    for measurement in measurementArr {
                        let m = Measurement(json: measurement);
                        //                    print("name:\((d?.name)!)")
                        if "PowerActive" == m?.value {
                            self.measurements.append(m!)
                        }
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
        self.measurementSearchBar.delegate = self
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        
    }
    
    // MARK: - SearchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print(selectedScope)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return (UIApplication.shared.delegate as? AppDelegate)!.appModel.selectedDeviceSet.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return measurements.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeasurementCell", for: indexPath)

        // Configure the cell...
        let measurement = measurements[indexPath.row]
        cell.textLabel?.text = measurement.valueName
        cell.detailTextLabel?.text = measurement.typeName

        return cell
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
