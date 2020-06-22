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
import FirebaseAuth
import FirebaseFirestore

private class PhoneNumberText: UITextField {
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
    var picker = CountryPicker()
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
        countryCodeTF.inputView = picker
        
        let locale = Locale.current
        let code = (locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String?
        
        picker.displayOnlyCountriesWithCodes = ["US"] // Display only
        picker.exeptCountriesWithCodes = ["RU"] // Exept country
        let theme = CountryViewTheme(countryCodeTextColor: .white, countryNameTextColor: .white, rowBackgroundColor: .clear, showFlagsBorder: false) // Optional for UIPickerView theme changes
        picker.theme = theme // Optional for UIPickerView theme changes
        picker.countryPickerDelegate = self
        picker.showPhoneNumbers = true
        picker.setCountry(code!)
    }
    
    // MARK: - Logic
    
    @objc private func handleEnterPhone() {
        let codeText = "\(countryCodeTF.text ?? "")\(phoneNumberTextField.text ?? "")"
        PhoneAuthProvider.provider().verifyPhoneNumber(codeText, uiDelegate: nil) { (verificationID, error) in
            if error != nil {
                // print(error.localizedDescription)
                // Show alert
                return
            } else {
                let defaults = UserDefaults.standard
                defaults.set(verificationID, forKey: "authVerificationID")
                self.goToVerify()
            }
        }
    }
    
    private func goToVerify() {
        let verifyController = VerifyViewController()
        verifyController.phoneNumber = "\(countryCodeTF.text ?? "")\(phoneNumberTextField.text ?? "")"
        let registerViewModel = RegistrationViewModel()
        registerViewModel.phone = phoneNumberTextField.text
        verifyController.modalPresentationStyle = .fullScreen
        present(verifyController, animated: true)
    }
    
    // MARK: - CountryPickerDelegate
    
    func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        //pick up anythink
        countryCodeTF.text = phoneCode
    }
    
    // MARK: - User Interface

    private func initializeUI() {
        view.backgroundColor = .white
        
        view.addSubview(label)
        label.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                            leading: view.leadingAnchor,
                            bottom: nil,
                            trailing: view.trailingAnchor,
                            padding: .init(top: 12, left: 30, bottom: 0, right: 30))
        
        let horizontalStack = UIStackView(arrangedSubviews: [countryCodeTF, phoneNumberTextField])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 11
        
        view.addSubview(horizontalStack)
        horizontalStack.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: view.bounds.height/5, left: 30, bottom: 0, right: 30))
        
        view.addSubview(underline)
        underline.anchor(top: countryCodeTF.bottomAnchor, leading: countryCodeTF.leadingAnchor, bottom: nil, trailing: countryCodeTF.trailingAnchor)
        
        view.addSubview(underline2)
        underline2.anchor(top: phoneNumberTextField.bottomAnchor, leading: phoneNumberTextField.leadingAnchor, bottom: nil, trailing: phoneNumberTextField.trailingAnchor)
        
        view.addSubview(sendButton)
        sendButton.anchor(top: underline2.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 20, left: 35, bottom: 0, right: 35))
        
        
    }
    
    private let phoneNumberTextField: UITextField = {
        let tf = PhoneNumberText()
        tf.keyboardType = UIKeyboardType.phonePad
        tf.placeholder = "1231231234"
        tf.backgroundColor = .white
        tf.font = UIFont.systemFont(ofSize: 27)
        tf.adjustsFontSizeToFitWidth = true
        tf.adjustsFontForContentSizeCategory = true
        tf.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        return tf
    }()
    
    private let countryCodeTF: UITextField = {
        let tf = PhoneNumberText()
        tf.keyboardType = UIKeyboardType.phonePad
        tf.text = "🇺🇸"
        tf.backgroundColor = .white
        tf.font = UIFont.systemFont(ofSize: 27)
        tf.textAlignment = .center
       // tf.adjustsFontSizeToFitWidth = true
        tf.widthAnchor.constraint(equalToConstant: 80).isActive = true
        tf.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        return tf
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Get Verification Code", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
   
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.layer.cornerRadius = 18
        
        button.addTarget(self, action: #selector(handleEnterPhone), for: .touchUpInside)
        return button
    }()
    
    private let label: UILabel = {
           let label = UILabel()
           label.text = "Enter Phone Number"
           label.textColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
           label.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
           label.textAlignment = .center
           label.adjustsFontSizeToFitWidth = true
           
           return label
       }()
    
    let underline: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 4).isActive = true
        view.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.6705882353, alpha: 1)
        return view
    }()
    
    let underline2: UIView = {
          let view = UIView()
          view.heightAnchor.constraint(equalToConstant: 4).isActive = true
          view.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.6713966727, alpha: 1)
          return view
      }()
}
