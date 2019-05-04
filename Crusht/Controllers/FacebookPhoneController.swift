////
////  FacebookPhoneController.swift
////  Crusht
////
////  Created by William Kelly on 1/30/19.
////  Copyright © 2019 William Kelly. All rights reserved.
////
//
//import UIKit
//import Firebase
//import UserNotifications
//import CountryPicker
//
//class FBPhoneNumberText: UITextField {
//    override func textRect(forBounds bounds: CGRect) -> CGRect {
//        return bounds.insetBy(dx: 24, dy: 0)
//    }
//    
//    override func editingRect(forBounds bounds: CGRect) -> CGRect {
//        return bounds.insetBy(dx: 24, dy: 0)
//    }
//    
//    override var intrinsicContentSize: CGSize {
//        return .init(width: 0, height: 100)
//    }
//}
//
//class FacebookPhoneController: UIViewController, UITextFieldDelegate, CountryPickerDelegate {
//    
//    var name: String?
//    
//    var fbid: String?
//
//    let FBgreetingLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
//        label.textAlignment = .center
//        label.numberOfLines = 0
//        label.text = "We need your phone number to match you with your contacts"
//        return label
//    }()
//    
//    let countryCodeTF: UITextField = {
//        let tf = FBPhoneNumberText()
//        tf.keyboardType = UIKeyboardType.phonePad
//        
//        tf.text = "🇺🇸"
//        
//        tf.backgroundColor = .white
//        tf.layer.cornerRadius = 15
//        tf.font = UIFont.systemFont(ofSize: 25)
//        tf.widthAnchor.constraint(equalToConstant: 80).isActive = true
//        tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        
//        
//        return tf
//    }()
//
//    let phoneNumberTextField: UITextField = {
//        let tf = FBPhoneNumberText()
//        tf.keyboardType = UIKeyboardType.phonePad
//        tf.placeholder = "3138886434"
//        tf.backgroundColor = .white
//        tf.layer.cornerRadius = 15
//        tf.font = UIFont.systemFont(ofSize: 25)
//        tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        
//        
//        return tf
//    }()
//    
//    let sendButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Get Verification Code", for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
//        button.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
//        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        button.widthAnchor.constraint(equalToConstant: 100)
//        button.titleLabel?.adjustsFontSizeToFitWidth = true
//        
//        button.layer.cornerRadius = 22
//        
//        button.addTarget(self, action: #selector(sendVerificationCode), for: .touchUpInside)
//        return button
//    }()
//    
//       var picker = CountryPicker()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        countryCodeTF.inputView = picker
//        
//        //Looks for single or multiple taps.
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        
//        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
//       // tap.cancelsTouchesInView = false
//        
//        view.addGestureRecognizer(tap)
//        
//        setupGradientLayer()
//        
//        let horizontalStack = UIStackView(arrangedSubviews: [countryCodeTF, phoneNumberTextField])
//        
//        horizontalStack.axis = .horizontal
//        horizontalStack.spacing = 11
//        
//        
//        let stack = UIStackView(arrangedSubviews: [FBgreetingLabel, horizontalStack, sendButton])
//        view.addSubview(stack)
//        
//        
//        stack.axis = .vertical
//        
//        stack.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: view.bounds.height/5, left: 30, bottom: view.bounds.height/2.2, right: 30))
//        
//        
//        stack.spacing = 20
//        
//  
//        
//        let locale = Locale.current
//        let code = (locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String?
//        //init Picker
//        picker.displayOnlyCountriesWithCodes = ["US", "DK", "SE", "NO", "DE"] //display only
//        picker.exeptCountriesWithCodes = ["RU"] //exept country
//        let theme = CountryViewTheme(countryCodeTextColor: .white, countryNameTextColor: .white, rowBackgroundColor: .clear, showFlagsBorder: false)        //optional for UIPickerView theme changes
//        picker.theme = theme //optional for UIPickerView theme changes
//        picker.countryPickerDelegate = self
//        picker.showPhoneNumbers = true
//        picker.setCountry(code!)
//        
//        
//    }
//    
//    func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
//        //pick up anythink
//        countryCodeTF.text = phoneCode
//    }
//    
//  @objc func dismissKeyboard() {
//        //Causes the view (or one of its embedded text fields) to resign the first responder status.
//        view.endEditing(true)
//    }
//    
//     @objc fileprivate func sendVerificationCode() {
//        print("button hit !")
//        if let phoneNumber = phoneNumberTextField.text,
//            let countryCode = countryCodeTF.text {
//            VerifyAPI.sendVerificationCode(countryCode, phoneNumber)
//            let checkVerification = CheckVerificationViewController()
//            checkVerification.countryCode = countryCode
//            checkVerification.phoneNumber = phoneNumber
//            checkVerification.fbid = fbid
//            present(checkVerification, animated: true)
//        }
//    }
//
//
//    fileprivate func goToVerify() {
//        let verifyController = VerifyViewController()
//        verifyController.phoneNumber = phoneNumberTextField.text
//        let registerViewModel = RegistrationViewModel()
//        registerViewModel.phone = phoneNumberTextField.text
//        present(verifyController, animated: true)
//    }
//    
//    let gradientLayer = CAGradientLayer()
//    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        gradientLayer.frame = view.bounds
//    }
//    
//    fileprivate func setupGradientLayer() {
//        
//        let topColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
//        let bottomColor = #colorLiteral(red: 0.8755432963, green: 0.4065410793, blue: 0, alpha: 1)
//        // make sure to user cgColor
//        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
//        gradientLayer.locations = [0, 1]
//        view.layer.addSublayer(gradientLayer)
//        gradientLayer.frame = view.bounds
//    }
//    
//}
