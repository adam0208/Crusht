//
//  YourSexController.swift
//  Crusht
//
//  Created by William Kelly on 4/12/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase

//class YourSexTextField: UITextField {
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

class YourSexController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let yourSexField: UITextField = {
        let tf = GenderTextField()
      
        tf.placeholder = "Select"
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 15
        tf.font = UIFont.systemFont(ofSize: 25)
        tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
        return tf
    }()
    
    let label: UILabel = {
        let label = UILabel()
        
        label.text = "Select Your Sex"
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
         label.textColor = .white
        return label
    }()
    
    let errorLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Please select an option"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        
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
        yourSexField.text = myPickerData[row]
        
    }
    var genderPicker = UIPickerView()
    
    let myPickerData = [String](arrayLiteral: "", "Male", "Female", "Other")
    
    var user: User?
    
    var gender = String()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        genderPicker.delegate = self
        view.addGradientSublayer()
        setUpUI()
    }
    
    fileprivate func setUpUI () {
       
            
            
            let stack = UIStackView(arrangedSubviews: [self.yourSexField, self.doneButton])
            self.view.addSubview(stack)
            
            stack.axis = .vertical
            
            self.view.addSubview(self.label)
            
            self.label.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, leading: self.view.leadingAnchor, bottom: nil, trailing: self.view.trailingAnchor, padding: .init(top: self.view.bounds.height/5, left: 30, bottom: 0, right: 30))
            
            stack.anchor(top: self.label.bottomAnchor, leading: self.view.leadingAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, trailing: self.view.trailingAnchor, padding: .init(top: 4, left: 30, bottom: self.view.bounds.height/2.2, right: 30))
            
            stack.spacing = 20
            
            self.yourSexField.inputView = self.genderPicker
        
        view.addSubview(errorLabel)
        errorLabel.isHidden = true
        errorLabel.anchor(top: stack.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 40, left: 20, bottom: 0, right: 20))
            
        
    }
    
    
    @objc fileprivate func handleDone() {
        
        
        if yourSexField.text == "" {
           errorLabel.isHidden = false
            return
        } else {
            
           
                
                self.gender = self.yourSexField.text ?? ""
                let genderPreference = GenderController()
                guard let uid = Auth.auth().currentUser?.uid else {return}
                let docData: [String: Any] = ["User-Gender": self.gender]
                Firestore.firestore().collection("users").document(uid).setData(docData, merge: true)
                //            genderPreference.name = name
                //            genderPreference.bio = bio
                //            genderPreference.age = age
                //            genderPreference.gender = gender
                //            genderPreference.birthday = birthday
                //            genderPreference.phone = phone
                //            genderPreference.school = school
                self.present(genderPreference, animated: true)
        
  
        }
        
    }
}
