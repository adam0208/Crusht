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
import CountryPicker

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

class PhoneNumberViewController: UIViewController, UITextFieldDelegate, CountryPickerDelegate {

    let phoneNumberTextField: UITextField = {
        let tf = PhoneNumberText()
        tf.keyboardType = UIKeyboardType.phonePad
        tf.placeholder = "3138886434"
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 15
        tf.font = UIFont.systemFont(ofSize: 25)
        tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
       
        return tf
    }()
    
    let countryCodeTF: UITextField = {
        let tf = PhoneNumberText()
        tf.keyboardType = UIKeyboardType.phonePad
        
        tf.text = "🇺🇸"
        
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 15
        tf.font = UIFont.systemFont(ofSize: 25)
        tf.widthAnchor.constraint(equalToConstant: 80).isActive = true
        tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
        return tf
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Get Verification Code", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100)
        button.titleLabel?.adjustsFontForContentSizeCategory = true

        
        button.layer.cornerRadius = 22
        
        button.addTarget(self, action: #selector(handleEnterPhone), for: .touchUpInside)
        return button
    }()
    
    var picker = CountryPicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientLayer()
        
        countryCodeTF.inputView = picker
        
        let horizontalStack = UIStackView(arrangedSubviews: [countryCodeTF, phoneNumberTextField])
       
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 11
        
        
        let stack = UIStackView(arrangedSubviews: [horizontalStack, sendButton])
        view.addSubview(stack)
        
        
        stack.axis = .vertical
        
        stack.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: view.bounds.height/3.5, left: 30, bottom: view.bounds.height/2.2, right: 30))
        
        
        stack.spacing = 20
        
        //phone picker
        
        let locale = Locale.current
        let code = (locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String?
        //init Picker
        picker.displayOnlyCountriesWithCodes = ["US", "DK", "SE", "NO", "DE"] //display only
        picker.exeptCountriesWithCodes = ["RU"] //exept country
        let theme = CountryViewTheme(countryCodeTextColor: .white, countryNameTextColor: .white, rowBackgroundColor: .clear, showFlagsBorder: false)        //optional for UIPickerView theme changes
        picker.theme = theme //optional for UIPickerView theme changes
        picker.countryPickerDelegate = self
        picker.showPhoneNumbers = true
        picker.setCountry(code!)
        

    }
    
    func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        //pick up anythink
        countryCodeTF.text = phoneCode
    }
    
    //@IBAction func enterPhone(_ sender: Any)
    @objc fileprivate func handleEnterPhone() {
        
        let codeText = "\(countryCodeTF.text ?? "")\(phoneNumberTextField.text ?? "")"
        
        let alert = UIAlertController(title: "Phone Number", message: "Is this your phone number? \n \(codeText)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Yes", style: .default){(UIAlertAction) in
            
            PhoneAuthProvider.provider().verifyPhoneNumber(codeText, uiDelegate: nil) { (verificationID, error) in
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
        verifyController.phoneNumber = "\(countryCodeTF.text ?? "")\(phoneNumberTextField.text ?? "")"
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
