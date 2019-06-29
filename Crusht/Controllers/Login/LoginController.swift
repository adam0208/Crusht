//
//  LoginController.swift
//  SwipeMatchFirestoreLBTA
//
//  Created by Brian Voong on 11/26/18.
//  Copyright © 2018 Brian Voong. All rights reserved.
//

import UIKit


protocol LoginControllerDelegate {
    func didFinishLoggingIn()
}

class LoginController: UIViewController {
    
    var delegate: LoginControllerDelegate?
    
}
