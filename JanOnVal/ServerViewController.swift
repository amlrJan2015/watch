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

class ServerViewController: UIViewController, UITextFieldDelegate, GIDSignInDelegate {
    @IBOutlet weak var serverUrl: UITextField!
    @IBOutlet weak var port: UITextField!
    @IBOutlet weak var projectName: UITextField!
    @IBOutlet weak var refreshTime: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        loadServerConfig()
        
        let tbc = tabBarController as? AppTabBarController
        appModel = tbc?.appModel
        appModel?.serverUrl = getWholeServerUrl()
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
        
        GIDSignIn.sharedInstance().delegate = self
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
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // ...
        if let error = error {
          print(error.localizedDescription)
          return
        }

        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (authResult, error) in
          if let error = error {
            self.showAlert("Error", error.localizedDescription)
            return
          }
          // User is signed in
          // ...
            print(authResult?.user.uid)
            authResult?.user.getIDTokenForcingRefresh(true, completion: { (idToken, error) in
                if let error = error {
                    self.showAlert("Error", error.localizedDescription)
                    return
                }
                
                print(idToken!)
            })
            self.addUserDataIfOk(authResult)
            if let authResult = authResult {
                let userDevicesDocRef = Firestore.firestore().document("/users/\(authResult.user.uid)");
                userDevicesDocRef.getDocument { (docSnapshot, error) in
                    let k = (docSnapshot?.data()?["devices"] as? [String:Bool])?.filter {$0.value}.keys
                    if let userRegisteredDevice = k {
                        let devicePath = Array<String>(userRegisteredDevice)[0]
                            print(devicePath)
                            
                    }
                }
            }
            
        }
    }
        
}
