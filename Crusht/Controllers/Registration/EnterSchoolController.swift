//
//  EnterSchoolController.swift
//  Crusht
//
//  Created by William Kelly on 4/14/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase

class EnterSchoolController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

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
        schoolTF.text = myPickerData[row]        
    }
    
    let myPickerData = Constants.universityList
    
    let schoolTF: UITextField = {
        let tf = NameTextField()
        
        tf.placeholder = "School"
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 15
        tf.font = UIFont.systemFont(ofSize: 25)
        tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
        return tf
    }()
    
    let label: UILabel = {
        let label = UILabel()
        
        label.text = "Select Your School/Alma Mater"
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
         label.textColor = .white
        
        return label
    }()
    
    let errorLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Please select your school/alma mater"
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
    
    var age = Int()
  var phone: String!
        
    @objc fileprivate func handleDone() {
        if schoolTF.text == "" {
            errorLabel.isHidden = false
            return
        }
        else {
         
            self.school = self.schoolTF.text ?? ""
            let bioController = YourSexController()
            
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let docData: [String: Any] = ["School": self.school]
            Firestore.firestore().collection("users").document(uid).setData(docData, merge: true)
//            bioController.name = name
//            bioController.school = school
//            bioController.birthday = birthday
//            bioController.age = age
//            bioController.phone = phone
            self.present(bioController, animated: true)
        
            
        }
        
    }
    
    var user: User?
    var birthday = String()
    var school = String()
    
    var name = String()
    
     var schoolPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        schoolPicker.delegate = self
        schoolTF.inputView = schoolPicker
        view.addGradientSublayer()
        
        let stack = UIStackView(arrangedSubviews: [schoolTF, doneButton])
        view.addSubview(stack)
        
        stack.axis = .vertical
        
        view.addSubview(label)
        
        label.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: view.bounds.height/5, left: 30, bottom: 0, right: 30))
        
        stack.anchor(top: label.bottomAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 10, left: 30, bottom: view.bounds.height/2.2, right: 30))
        
        stack.spacing = 20
        
        view.addSubview(errorLabel)
        errorLabel.isHidden = true
        errorLabel.anchor(top: stack.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 40, left: 20, bottom: 0, right: 20))
        
        
        
    }

}
