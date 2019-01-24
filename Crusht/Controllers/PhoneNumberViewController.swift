//
//  PhoneNumberViewController.swift
//  Crusht
//
//  Created by William Kelly on 1/20/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

class PhoneNumberText: UITextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 24, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 24, dy: 0)
    }
    
    override var intrinsicContentSize: CGSize {
        return .init(width: 0, height: 100)
    }
}

class PhoneNumberViewController: UIViewController, UITextFieldDelegate {

    let phoneNumberTextField: UITextField = {
        let tf = PhoneNumberText()
        tf.keyboardType = UIKeyboardType.phonePad
        tf.placeholder = "+19177449835"
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 22
        tf.font = UIFont.systemFont(ofSize: 30)
        tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
       
        return tf
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Get Verification Code", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 0, alpha: 1)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100)
        
        button.layer.cornerRadius = 22
        
        button.addTarget(self, action: #selector(handleEnterPhone), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientLayer()
        
        let stack = UIStackView(arrangedSubviews: [phoneNumberTextField, sendButton])
        view.addSubview(stack)
        
        stack.axis = .vertical
        
        stack.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 250, left: 30, bottom: 250, right: 30))
        
        
        stack.spacing = 20
        

    }
    
    //@IBAction func enterPhone(_ sender: Any)
    @objc fileprivate func handleEnterPhone() {
        
        let alert = UIAlertController(title: "Phone Number", message: "Is this your phone number? \n \(phoneNumberTextField.text!)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Yes", style: .default){(UIAlertAction) in
            PhoneAuthProvider.provider().verifyPhoneNumber(self.phoneNumberTextField.text!, uiDelegate: nil) { (verificationID, error) in
                if let error = error {
                    print(error.localizedDescription)
                    //show alert
                    return
                }  else{
                    let defaults = UserDefaults.standard
                    defaults.set(verificationID, forKey: "authVerificationID")
                    
                    self.goToVerify()
                }
            }
        }
        let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    fileprivate func goToVerify() {
        let verifyController = VerifyViewController()
        verifyController.phoneNumber = phoneNumberTextField.text
        let registerViewModel = RegistrationViewModel()
        registerViewModel.phone = phoneNumberTextField.text
        present(verifyController, animated: true)
    }
    
    let gradientLayer = CAGradientLayer()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.bounds
        
    }
    
    fileprivate func setupGradientLayer() {
        
        let topColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        let bottomColor = #colorLiteral(red: 0.8755432963, green: 0.4065410793, blue: 0, alpha: 1)
        // make sure to user cgColor
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0, 1]
        view.layer.addSublayer(gradientLayer)
        gradientLayer.frame = view.bounds
    }
    
}
