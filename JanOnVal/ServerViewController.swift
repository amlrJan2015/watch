//
//  ServerViewController.swift
//  JanOnVal
//
//  Created by Andreas Mueller on 26.01.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseFirestore
import FirebaseAuth
//import CloudKit
import os.log

class ServerViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var serverUrl: UITextField!
    @IBOutlet weak var port: UITextField!
    @IBOutlet weak var projectName: UITextField!
    @IBOutlet weak var refreshTime: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var janitzaID: UILabel!
    @IBOutlet weak var cloud: UILabel!
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
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
    
    var handleJanitzaID: AuthStateDidChangeListenerHandle?
    var handleJanitzaCloud: AuthStateDidChangeListenerHandle?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadServerConfig()
        
        let tbc = tabBarController as? AppTabBarController
        appModel = tbc?.appModel
        appModel?.serverUrl = getWholeServerUrl()
        
        guard let janitzaIDApp = FirebaseApp.app(name: "JanitzID") else {
            assert(false,"Could not retrieve secondary app!!!")
            return
        }
        
        handleJanitzaID = Auth.auth(app: janitzaIDApp).addStateDidChangeListener { (auth, user) in
            if let name = user?.displayName {
                self.janitzaID.text = "🟢"
            } else {
                self.janitzaID.text = "🔴"
            }
        }
        handleJanitzaCloud = Auth.auth().addStateDidChangeListener { (auth, user) in
            print("+++++++++Auth\(user?.displayName ?? "out")")
            if let name = user?.displayName {
                self.cloud.text = "🟢"
            } else {
                self.cloud.text = "🔴"
            }
            if let user = user {
                user.getIDTokenForcingRefresh(true, completion: { (cloudToken, cloudTokenErr) in
                    if let error = cloudTokenErr {
                        print("Error get Cloud token", error.localizedDescription)
                        self.showAlert("Error get Cloud token", error.localizedDescription)
                        return
                    }
                    
                    print("#+#+#+#+#CloudToken:",cloudToken!)
                    let connectivityHandlerOpt = (UIApplication.shared.delegate as? AppDelegate)?.connectivityHandler
                    if let connectivityHandler = connectivityHandlerOpt {
                        if connectivityHandler.session.activationState == .activated {
                            Firestore.firestore().collectionGroup("Devices").whereField("owner", isEqualTo: user.uid).getDocuments { (querySnapshot, devicesErr) in
                                if let err = devicesErr {
                                    print("Error getting documents: \(err)")
                                } else {
                                    var firestoreData: [[String:String]] = []
                                    var hubId: String = ""
                                    for document in querySnapshot!.documents {
                                        let data = document.data()
                                        print("\(document.documentID) => \(data["deviceName"] as? String ?? "Unknown")")
                                        hubId = data["hubId"] as! String
                                        let dict: [String:String] = [
                                            "deviceID": document.documentID,
                                            "hubID": hubId,
                                            "deviceName": data["deviceName"] as? String ?? "Unknown"
                                        ]
                                        firestoreData.append(dict)
                                    }
                                    
                                    connectivityHandler.session.transferUserInfo([
                                        "cloudToken": cloudToken!,
                                        "firestoreData": firestoreData,
                                        "consumers": firestoreData.count
                                    ])
                                    
                                    self.showAlert("Info","Cloud token was refreshed.")
                                    
                                }
                            }
                            
                        } else {
                            print("Error","ConnectivityHandler state is not active!")
                        }
                    } else {
                        print("Error","No connectivityHandler!")
                    }
                })
            } else {
                print("nicht eingelogt")
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // [START remove_auth_listener]
        Auth.auth().removeStateDidChangeListener(handleJanitzaID!)
        Auth.auth().removeStateDidChangeListener(handleJanitzaCloud!)
        // [END remove_auth_listener]
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
    
    var cloudDB: Firestore!
    
    private func addOrUpdateUserData(_ userUUID: String, _ fcmToken: String ) {
        let userDocRef = Firestore.firestore().document("/users/\(userUUID)");
        userDocRef.setData([
            "fcmToken": fcmToken
        ], merge: true) { (errorOpt) in
            if let err = errorOpt {
                self.showAlert("Error", "Benutzerdaten konnten nicht aktualisiert werden. Info:\(err.localizedDescription)")
            }
        }
    }
    
    fileprivate func addUserDataIfOk(_ authDataResultOpt: AuthDataResult?) {
        if let authDataResult = authDataResultOpt {
            UserDefaults.standard.set(authDataResult.user.uid, forKey: "userUUID")
            if let fcmToken = UserDefaults.standard.string(forKey: "fcmToken") {
                addOrUpdateUserData(authDataResult.user.uid, fcmToken)
                self.showAlert("Success", "User has been logged in.")
                
            } else {
                self.showAlert("Error", "Firebase Cloud Messaging is not ready.")
            }
        } else {
            self.showAlert("Error", "AuthDataResult has been not set.")
        }
    }
    
    @IBAction func signIn(_ sender: Any) {
        sign()
    }
    
    
    @IBAction func onLogoutClick(_ sender: UIButton) {
        guard let janitzaIDApp = FirebaseApp.app(name: "JanitzID") else {
            assert(false,"Could not retrieve secondary app!!!")
            return
        }
        
        let cloudAuth = Auth.auth()
        let janitzaIdAuth = Auth.auth(app: janitzaIDApp)
        do {
            try cloudAuth.signOut()
            try janitzaIdAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
            self.showAlert("Error signing out","signOutError")
        }
    }
    
    func sign() {
        
        guard let clientID = FirebaseApp.app(name: "JanitzID")?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            //            guard let authentication = user.authentication else { return }
            //            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
            //                                                           accessToken: authentication.accessToken)
            
            self.cloud.text = "🟢"
            
            guard let janitzaIDApp = FirebaseApp.app(name: "JanitzID") else {
                assert(false,"Could not retrieve secondary app!!!")
                return
            }
            
            Auth.auth(app: janitzaIDApp).signIn(with: credential) { (authResultJanitzaID, error) in
                if let error = error {
                    print("JanitzaIDAuth-ERROR:\(error.localizedDescription)")
                    //                self.showAlert("Error", error.localizedDescription)
                    return
                }
                // User is signed in
                // ...
                print("USerID_JanitzaID(lVgE...):",authResultJanitzaID?.user.uid ?? "Error on fetch user id")
                
                
                let functions = Functions.functions(app: janitzaIDApp, region: "europe-west1")
                
                functions.httpsCallable("createCustomAuthToken").call { (resultopt, cloudFunctionCallErrOpt) in
                    
                    if let cloudFunctionCallErr = cloudFunctionCallErrOpt {
                        print("Error Cloud Function Call", cloudFunctionCallErr.localizedDescription)
                        //                    self.showAlert("Error Cloud Function Call", cloudFunctionCallErr.localizedDescription)
                        return
                    }
                    
                    if let result = resultopt {
                        
                        let customerToken = result.data as! String
                        
                        Auth.auth().signIn(withCustomToken: customerToken) { (authResultCloud, cloudError) in
                            if let cloudError = cloudError {
                                print("Cloud Auth Error", cloudError.localizedDescription, customerToken)
                                //                            self.showAlert("Cloud Auth Error", cloudError.localizedDescription)
                                return
                            }
                            
                            
                            print("USerID_JanitzaCloud(lVgE...):",authResultCloud?.user.uid ?? "Error on fetch user id")
                            
                            
                            //                        self.addUserDataIfOk(authResultCloud)
                            //                        if let authResult = authResultCloud {
                            //
                            //                            let userDevicesDocRef = Firestore.firestore().document("/users/\(authResult.user.uid)");
                            //                            userDevicesDocRef.getDocument { (docSnapshot, error) in
                            //                                let k = (docSnapshot?.data()?["devices"] as? [String:Bool])?.filter {$0.value}.keys
                            //                                if let userRegisteredDevice = k {
                            //                                    let devicePath = Array<String>(userRegisteredDevice)[0]
                            //                                    print(devicePath)
                            //
                            //                                }
                            //                            }
                            //
                            //                        }
                            
                            authResultCloud?.user.getIDTokenForcingRefresh(true, completion: { (cloudToken, error) in
                                if let error = error {
                                    print("Error get Cloud token", error.localizedDescription)
                                    //                                self.showAlert("Error", error.localizedDescription)
                                    return
                                }
                                
                                print("#+#+#+#+#CloudToken:",cloudToken!)
                                let connectivityHandlerOpt = (UIApplication.shared.delegate as? AppDelegate)?.connectivityHandler
                                if let connectivityHandler = connectivityHandlerOpt {
                                    if connectivityHandler.session.activationState == .activated {
                                        
                                        if let authRC = authResultCloud {
                                            
                                            Firestore.firestore().collectionGroup("Devices").whereField("owner", isEqualTo: authRC.user.uid).getDocuments { (querySnapshot, devicesErr) in
                                                if let err = devicesErr {
                                                    print("Error getting documents: \(err)")
                                                } else {
                                                    var firestoreData: [[String:String]] = []
                                                    var hubId: String = ""
                                                    for document in querySnapshot!.documents {
                                                        let data = document.data()
                                                        print("\(document.documentID) => \(data["deviceName"] as! String)")
                                                        hubId = data["hubId"] as! String
                                                        let dict: [String:String] = [
                                                            "deviceID": document.documentID,
                                                            "hubID": hubId,
                                                            "deviceName": data["deviceName"] as! String
                                                        ]
                                                        firestoreData.append(dict)
                                                    }
                                                    
                                                    connectivityHandler.session.transferUserInfo([
                                                        "cloudToken": cloudToken!,
                                                        "firestoreData": firestoreData,
                                                        "consumers": firestoreData.count
                                                    ])
                                                    
                                                    //                                                Firestore.firestore().collection("ConsumerConfig").whereField("hubId", isEqualTo: hubId).getDocuments { (querySnapshotConsumers, conusmersErr) in
                                                    //                                                    if let err = conusmersErr {
                                                    //                                                        print("Error getting consumers: \(err)")
                                                    //                                                    } else {
                                                    //                                                        let isConsumerExists: Bool = querySnapshotConsumers!.documents.count > 0
                                                    //                                                        var consumersCount: Int = 0
                                                    //                                                        if isConsumerExists {
                                                    //                                                            if let consumers = querySnapshotConsumers!.documents[0].data()["consumers"] as? [String: Any]{
                                                    //                                                                consumersCount = consumers.count
                                                    //                                                            }
                                                    //                                                        }
                                                    //
                                                    //                                                        connectivityHandler.session.transferUserInfo([
                                                    //                                                            "cloudToken": cloudToken!,
                                                    //                                                            "firestoreData": firestoreData,
                                                    //                                                            "consumers": consumersCount
                                                    //                                                        ])
                                                    //                                                    }
                                                    //                                                }
                                                }
                                            }
                                        }
                                    } else {
                                        print("Error","No connectivityHandler!")
                                        //                                    self.showAlert("Error","No connectivityHandler!")
                                    }
                                } else {
                                    print("Error","No connectivityHandler!")
                                    //                                self.showAlert("Error","No connectivityHandler!")
                                }
                            })
                        }
                    }
                }
            }
        }
        
    }
    
}
