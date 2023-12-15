//
//  ServerViewController.swift
//  JanOnVal
//
//  Created by Andreas Mueller on 26.01.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import UIKit
//import CloudKit
import os.log
import SwiftUI

class ServerViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var serverUrl: UITextField!
    @IBOutlet weak var port: UITextField!
    @IBOutlet weak var projectName: UITextField!
    @IBOutlet weak var refreshTime: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
        
    
    //private let defaultContainer = CKContainer.default()
    
    /// This sample uses the private database, which requires a logged in iCloud account.
    //private lazy var database = defaultContainer.privateCloudDatabase
    
    //private let lastPersonRecordID: CKRecord.ID = CKRecord.ID(recordName: "config")
    
    var appModel: AppModel?
    
    let defaults = UserDefaults.standard
    let HOST = "HOST"
    let PORT = "PORT"
    let PROJECT = "PROJECT"
    let REFRESH_TIME = "REFRESH_TIME"
    
    private func loadServerConfig() {
        serverUrl.text = defaults.string(forKey: HOST) ?? "https://gridvis-ems.janitza.de"
        port.text = defaults.string(forKey: PORT) ?? "443"
        projectName.text = defaults.string(forKey: PROJECT) ?? "EnergieManagementSystem Janitza"
        refreshTime.text = defaults.string(forKey: REFRESH_TIME) ?? "2"
    }
    
    
    /*func saveRecord(name: String, refreshTime: Int, serverURL: String, port: String, projectName: String) {
        let lastPersonRecord = CKRecord(recordType: "Config", recordID: lastPersonRecordID)
        
        lastPersonRecord["name"] = name
        lastPersonRecord["refreshTime"] = refreshTime
        lastPersonRecord["serverUrl"] = serverURL
        lastPersonRecord["port"] = port
        lastPersonRecord["projectName"] = projectName

        database.modifyRecords(saving: [lastPersonRecord], deleting: [], savePolicy: .changedKeys, atomically: true) { result in
            switch result {
            case .success(let successInfo):
                print("Save to Cloud SUCCESS[\(successInfo.saveResults.count)]")
                break
            case .failure(let error):
                self.reportError(error)
            }
        }
    }
    
    private func reportError(_ error: Error) {
        guard let ckerror = error as? CKError else {
            os_log("Not a CKError: \(error.localizedDescription)")
            return
        }

        switch ckerror.code {
        case .partialFailure:
            // Iterate through error(s) in partial failure and report each one.
            let dict = ckerror.userInfo[CKPartialErrorsByItemIDKey] as? [NSObject: CKError]
            if let errorDictionary = dict {
                for (_, error) in errorDictionary {
                    reportError(error)
                }
            }

        // This switch could explicitly handle as many specific errors as needed, for example:
        case .unknownItem:
            os_log("CKError: Record not found.")

        case .notAuthenticated:
            os_log("CKError: An iCloud account must be signed in on device or Simulator to write to a PrivateDB.")

        case .permissionFailure:
            os_log("CKError: An iCloud account permission failure occured.")

        case .networkUnavailable:
            os_log("CKError: The network is unavailable.")

        default:
            os_log("CKError: \(error.localizedDescription)")
        }
    }*/
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadServerConfig()
        
        let tbc = tabBarController as? AppTabBarController
        appModel = tbc?.appModel
        appModel?.serverUrl = getWholeServerUrl()
        
        
        if let unarchivedObject = UserDefaults.standard.data(forKey: Measurement.KEY_FOR_USER_DEFAULTS) {
            do {
                appModel?.data = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(unarchivedObject) as! [Measurement]
            } catch {
                fatalError("loadWidgetDataArray - Can't encode data: \(error)")
            }
        }
    }
    
    func saveServerConfig() {
        appModel!.serverUrl = getWholeServerUrl()
        appModel!.refreshTime = Int((refreshTime.text)!) ?? 5
        
        defaults.set(serverUrl.text, forKey: HOST)
        defaults.set(port.text, forKey: PORT)
        defaults.set(projectName.text, forKey: PROJECT)
        defaults.set(appModel!.refreshTime, forKey: REFRESH_TIME)
        
        /*saveRecord(name: "defaultSettings", refreshTime: appModel!.refreshTime, serverURL: serverUrl.text ?? "serverURL", port: port.text ?? "port", projectName: projectName.text ?? "projectName")*/
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serverUrl.delegate = self
        port.delegate = self
        projectName.delegate = self
        refreshTime.delegate = self
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveServerConfig()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func getWholeServerUrl() -> String {
        let portStr = "" == port.text! ? "" : ":\(port.text!)"
        let encodedProjectName = projectName.text!.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        return "\(serverUrl.text!)\(portStr)/rest/1/projects/\(encodedProjectName)/"
    }
    
    fileprivate func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        do {
            if !(appModel?.data ?? []).isEmpty {
                let vc = UIHostingController(rootView: ValuesScreen(configData: appModel?.data ?? [], viewModel: MeasurementValueViewModel(serverUrl: appModel!.serverUrl, refreshTime: appModel!.refreshTime, measurementData: appModel?.getMeasurementData() ?? [])))
                present(vc, animated: true)
            }
        } catch {
            fatalError("Can't encode selected data: \(error)")
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
