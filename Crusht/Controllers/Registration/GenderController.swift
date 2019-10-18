//
//  GenderController.swift
//  Crusht
//
//  Created by William Kelly on 4/12/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase

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
         label.textColor = .white
        return label
    }()
    
    let errorLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Please select a preference"
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
        genderTextField.text = myPickerData[row]
        
    }
    var genderPicker = UIPickerView()
    
    let myPickerData = [String](arrayLiteral: "", "Male", "Female", "All Humans")
    
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
       
        genderPicker.delegate = self
        
        view.addGradientSublayer()
    
        let stack = UIStackView(arrangedSubviews: [genderTextField, doneButton])
        view.addSubview(stack)
        
        stack.axis = .vertical
        
        view.addSubview(label)
        
        label.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: view.bounds.height/5, left: 30, bottom: 0, right: 30))
        
        stack.anchor(top: label.bottomAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 4, left: 30, bottom: view.bounds.height/2.2, right: 30))
        
        stack.spacing = 20
        
        genderTextField.inputView = genderPicker
        
        view.addSubview(errorLabel)
        errorLabel.isHidden = true
        errorLabel.anchor(top: stack.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 40, left: 20, bottom: 0, right: 20))
        
    }
    
    var name = String()
    var birthday = String()
    var bio = String()
    var school = String()
    var age = Int()
    var phone: String!
    var gender = String()
    var sexYouLike = String()
    

    
    @objc fileprivate func handleDone() {
    
       
        if genderTextField.text == "" {
            errorLabel.isHidden = false
            return
        } else {
            
                self.sexYouLike = self.genderTextField.text ?? ""
            let photoCnotroller = BioController()
            guard let uid = Auth.auth().currentUser?.uid else {return}
                let docData: [String: Any] = ["Gender-Preference": self.sexYouLike]
            Firestore.firestore().collection("users").document(uid).setData(docData, merge: true)
//            photoCnotroller.age = age
//            photoCnotroller.name = name
//            photoCnotroller.birthday = birthday
//            photoCnotroller.phone = phone
//            photoCnotroller.bio = bio
//            photoCnotroller.school = school
//            photoCnotroller.gender = gender
//            photoCnotroller.sexYouLike = sexYouLike
           self.present(photoCnotroller, animated: true)
            
        }
        
    }
}
