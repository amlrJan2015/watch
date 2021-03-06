//
//  AppTabBarController.swift
//  JanOnVal
//
//  Created by Andreas Müller on 02.02.18.
//  Copyright © 2018 Andreas Mueller. All rights reserved.
//

import UIKit

class AppTabBarController: UITabBarController {
    var appModel = AppModel()
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let serverView = viewControllers![0] as? ServerViewController {
            if selectedIndex == 0{
                serverView.saveServerConfig()
            }
        }
        
    }
}
