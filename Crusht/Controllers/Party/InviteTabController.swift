////
////  InviteTabController.swift
////  Crusht
////
////  Created by William Kelly on 2/25/20.
////  Copyright © 2020 William Kelly. All rights reserved.
////
//
//import UIKit
//
//class InviteTabController: UITabBarController {
//
//      let contactsController = InviteController()
//        let schoolController = SchoolInviteController()
//     
//        
//       override func viewDidLoad() {
//            super.viewDidLoad()
//        
//            let contactsNav = UINavigationController(rootViewController: contactsController)
//            contactsNav.tabBarItem.title = "Contacts"
//            contactsNav.tabBarItem.image = #imageLiteral(resourceName: "icons8-phone-30-2").withRenderingMode(.alwaysOriginal)
//            contactsNav.tabBarController?.tabBar.isTranslucent = false
//        
//            let schoolNave = UINavigationController(rootViewController: schoolController)
//            schoolNave.tabBarItem.title = "School"
//            schoolNave.tabBarItem.image = #imageLiteral(resourceName: "icons8-mortarboard-30-2").withRenderingMode(.alwaysOriginal)
//            schoolNave.tabBarController?.tabBar.isTranslucent = false
// 
//            
//            viewControllers = [contactsNav, schoolNave]
//        }
//    }
