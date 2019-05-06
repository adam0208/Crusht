//
//  CustomTabBarController.swift
//  Crusht
//
//  Created by William Kelly on 5/4/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    let contactsController = FindCrushesTableViewController()
    let schoolController = SchoolCrushController()
    let venueController = BarsTableView()
    let messageController = MessageController()
    
   override func viewDidLoad() {
        super.viewDidLoad()
    
        let contactsNav = UINavigationController(rootViewController: contactsController)
        contactsNav.tabBarItem.title = "Contacts"
        contactsNav.tabBarItem.image = #imageLiteral(resourceName: "icons8-phone-30-2").withRenderingMode(.alwaysOriginal)
        contactsNav.tabBarController?.tabBar.isTranslucent = false
    
        let schoolNave = UINavigationController(rootViewController: schoolController)
        schoolNave.tabBarItem.title = "School"
        schoolNave.tabBarItem.image = #imageLiteral(resourceName: "icons8-mortarboard-30-2").withRenderingMode(.alwaysOriginal)
        schoolNave.tabBarController?.tabBar.isTranslucent = false
        let venueNav = UINavigationController(rootViewController: venueController)
        venueNav.tabBarItem.title = "Venues"
        venueNav.tabBarItem.image = #imageLiteral(resourceName: "icons8-bar-30-2").withRenderingMode(.alwaysOriginal)
        venueNav.tabBarController?.tabBar.isTranslucent = false
    
        let messageNave = UINavigationController(rootViewController: messageController)
        messageNave.tabBarItem.title = "Messages"
        messageNave.tabBarItem.image = #imageLiteral(resourceName: "icons8-communication-30").withRenderingMode(.alwaysOriginal)
        messageNave.tabBarController?.tabBar.isTranslucent = false
    
    
        tabBarController?.tabBar.backgroundColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
        
        viewControllers = [contactsNav, schoolNave, venueNav, messageNave]
    }
}
