//
//  ViewController.swift
//  JanOnVal
//
//  Created by Christian Stolz on 08.12.17.
//  Copyright © 2017 Andreas Mueller. All rights reserved.
//
import UIKit
import WatchConnectivity

class ViewController: UIViewController {
    
    var connectivityHandler: ConnectivityHandler!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.connectivityHandler = (UIApplication.shared.delegate as? AppDelegate)?.connectivityHandler
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var rest1: UITextField!
    @IBOutlet weak var rest2: UITextField!
    @IBOutlet weak var serverUrl: UITextField!

    
    @IBAction func actionBtn(_ sender: UIButton) {
        
        connectivityHandler.session.sendMessage(
            [
                "serverUrl": serverUrl.text,
                "ep1": rest1.text,
                "ep2": rest2.text
        ], replyHandler: nil) { (err) in
            NSLog("%@", "Error sending data to watch: \(err)")
        }        
    }
}

