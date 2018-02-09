//
//  ServerViewController.swift
//  JanOnVal
//
//  Created by Christian Stolz on 26.01.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import UIKit

class ServerViewController: UIViewController {
    var appModel: AppModel?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        (UIApplication.shared.delegate as? AppDelegate)?.appModel.serverUrl = serverUrl.text!
        let tbc = tabBarController as? AppTabBarController
        appModel = tbc?.appModel
        appModel?.serverUrl = serverUrl.text!        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBOutlet weak var serverUrl: UITextField!
    
    
    @IBAction func onChangeServerUrl(_ sender: UITextField) {
        
//        (UIApplication.shared.delegate as? AppDelegate)?.appModel.serverUrl = sender.text!
        appModel?.serverUrl = sender.text!
    }
}
