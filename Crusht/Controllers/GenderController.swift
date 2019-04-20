//
//  GenderController.swift
//  Crusht
//
//  Created by William Kelly on 4/12/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class GenderTextField: UITextField {
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

class GenderController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let genderTextField: UITextField = {
        let tf = GenderTextField()
        tf.keyboardType = UIKeyboardType.phonePad
        tf.placeholder = "Select"
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 15
        tf.font = UIFont.systemFont(ofSize: 25)
        tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
        return tf
    }()
    
    let label: UILabel = {
        let label = UILabel()
        
        label.text = "Select Sex Preference"
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        
        label.textColor = .black
        return label
    }()

    
    let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        
        button.layer.cornerRadius = 22
        
        button.addTarget(self, action: #selector(handleDone), for: .touchUpInside)
        
        return button
    }()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myPickerData.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return myPickerData[row]
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTextField.text = myPickerData[row]
        
    }
    var genderPicker = UIPickerView()
    
    let myPickerData = [String](arrayLiteral: " ", "Humans With Penises", "Humans With Vaginas", "All Humans")
    
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        genderPicker.delegate = self
        
        setupGradientLayer()
    
        let stack = UIStackView(arrangedSubviews: [genderTextField, doneButton])
        view.addSubview(stack)
        
        stack.axis = .vertical
        
        view.addSubview(label)
        
        label.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: view.bounds.height/5, left: 30, bottom: 0, right: 30))
        
        stack.anchor(top: label.bottomAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 4, left: 30, bottom: view.bounds.height/2.2, right: 30))
        
        stack.spacing = 20
        
        genderTextField.inputView = genderPicker
        
    }
    
    var name = String()
    var birthday = String()
    var bio = String()
    var school = String()
    var age = Int()
    var phone = String()
    var gender = String()
    var sexYouLike = String()
    

    
    @objc fileprivate func handleDone() {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Select a preference"
        if genderTextField.text == "" {
            hud.show(in: view)
            hud.dismiss(afterDelay: 2)
            return
        } else {
            sexYouLike = genderTextField.text ?? ""
            let photoCnotroller = EnterPhotoController()
            photoCnotroller.age = age
            photoCnotroller.name = name
            photoCnotroller.birthday = birthday
            photoCnotroller.phone = phone
            photoCnotroller.bio = bio
            photoCnotroller.school = school
            photoCnotroller.gender = gender
            photoCnotroller.sexYouLike = sexYouLike
            present(photoCnotroller, animated: true)
        }
        
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
