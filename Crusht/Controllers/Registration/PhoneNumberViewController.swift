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
        present(verifyController, animated: true)
    }
    
    // MARK: - CountryPickerDelegate
    
    func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        //pick up anythink
        countryCodeTF.text = phoneCode
    }
    
    // MARK: - User Interface

    private func initializeUI() {
        view.addGradientSublayer()
        view.addSubview(label)
        let horizontalStack = UIStackView(arrangedSubviews: [countryCodeTF, phoneNumberTextField])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 11
        let stack = UIStackView(arrangedSubviews: [horizontalStack, sendButton])
        view.addSubview(stack)
        stack.axis = .vertical
        
        label.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                     leading: view.leadingAnchor,
                     bottom: nil,
                     trailing: view.trailingAnchor,
                     padding: .init(top: view.bounds.height / 5, left: 30, bottom: 0, right: 30))
        
        stack.anchor(top: label.bottomAnchor,
                     leading: view.leadingAnchor,
                     bottom: view.safeAreaLayoutGuide.bottomAnchor,
                     trailing: view.trailingAnchor,
                     padding: .init(top: 4, left: 30, bottom: view.bounds.height / 2.2, right: 30))
        
        stack.spacing = 20
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Enter Phone Number"
        label.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.numberOfLines = 0
        
        return label
    }()
    
    private let phoneNumberTextField: UITextField = {
        let tf = PhoneNumberText()
        tf.keyboardType = UIKeyboardType.phonePad
        tf.placeholder = "3138886434"
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 15
        tf.font = UIFont.systemFont(ofSize: 25)
        tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        return tf
    }()
    
    private let countryCodeTF: UITextField = {
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
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Get Verification Code", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.layer.cornerRadius = 22
        
        button.addTarget(self, action: #selector(handleEnterPhone), for: .touchUpInside)
        return button
    }()
}
