//
//  YourSexController.swift
//  Crusht
//
//  Created by William Kelly on 4/12/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase

class YourSexController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var genderPicker = UIPickerView()
    var user: User?
    var gender = String()
    
    let myPickerData = [String](arrayLiteral: "", "Male", "Female", "Other")
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        genderPicker.delegate = self
        initializeUI()
    }
    
    // MARK: - Logic
    
    @objc private func handleDone() {
        guard yourSexField.text != "" else {
            errorLabel.isHidden = false
            return
        }
        self.gender = self.yourSexField.text ?? ""
        let genderPreference = GenderController()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let docData: [String: Any] = ["User-Gender": self.gender]
        Firestore.firestore().collection("users").document(uid).setData(docData, merge: true)
        self.present(genderPreference, animated: true)
    }
    
    // MARK: - UIPickerViewDelegate, UIPickerViewDataSource
    
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
    
    // MARK: - User Interface
    
    private func initializeUI() {
        view.addGradientSublayer()
        let stack = UIStackView(arrangedSubviews: [self.yourSexField, self.doneButton])
        self.view.addSubview(stack)
        stack.axis = .vertical
        self.view.addSubview(self.label)
        self.label.anchor(top: self.view.safeAreaLayoutGuide.topAnchor,
                          leading: self.view.leadingAnchor,
                          bottom: nil,
                          trailing: self.view.trailingAnchor,
                          padding: .init(top: self.view.bounds.height / 5, left: 30, bottom: 0, right: 30))
        
        stack.anchor(top: self.label.bottomAnchor,
                     leading: self.view.leadingAnchor,
                     bottom: self.view.safeAreaLayoutGuide.bottomAnchor,
                     trailing: self.view.trailingAnchor,
                     padding: .init(top: 4, left: 30, bottom: self.view.bounds.height / 2.2, right: 30))
        
        stack.spacing = 20
        self.yourSexField.inputView = self.genderPicker
        view.addSubview(errorLabel)
        errorLabel.isHidden = true
        errorLabel.anchor(top: stack.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 40, left: 20, bottom: 0, right: 20))
    }
    
    private let yourSexField: UITextField = {
        let tf = GenderTextField()
        tf.placeholder = "Select"
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 15
        tf.font = UIFont.systemFont(ofSize: 25)
        tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        return tf
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        
        label.text = "Select Your Sex"
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        return label
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Please select an option"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    private let doneButton: UIButton = {
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
}
