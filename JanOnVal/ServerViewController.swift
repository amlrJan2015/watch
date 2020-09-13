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

class ServerViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var serverUrl: UITextField!
    @IBOutlet weak var port: UITextField!
    @IBOutlet weak var projectName: UITextField!
    @IBOutlet weak var refreshTime: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var janitzaID: UILabel!
    @IBOutlet weak var cloud: UILabel!
    
    var appModel: AppModel?
    
    let defaults = UserDefaults.standard
    let HOST = "HOST"
    let PORT = "PORT"
    let PROJECT = "PROJECT"
    let REFRESH_TIME = "REFRESH_TIME"
    
    private func loadServerConfig() {
        serverUrl.text = defaults.string(forKey: HOST) ?? "http://gridvis-ems.srv"
        port.text = defaults.string(forKey: PORT) ?? "8080"
        projectName.text = defaults.string(forKey: PROJECT) ?? "EnergieManagementSystem Janitza"
        refreshTime.text = defaults.string(forKey: REFRESH_TIME) ?? "2"
    }
    
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
                                    
                                    self.showAlert("Info","Cloud token was refreshed.")
                                    
                                }
                            }
                            
                        } else {
                            print("Error","ConnectivityHandler state is not active!")
                            self.showAlert("Error","No connectivityHandler!")
                        }
                    } else {
                        print("Error","No connectivityHandler!")
                        self.showAlert("Error","No connectivityHandler!")
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serverUrl.delegate = self
        port.delegate = self
        projectName.delegate = self
        refreshTime.delegate = self
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
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
    
}
