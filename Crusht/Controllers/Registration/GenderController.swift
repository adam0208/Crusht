//
//  GenderController.swift
//  Crusht
//
//  Created by William Kelly on 4/12/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class GenderController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var name = String()
    var birthday = String()
    var bio = String()
    var school = String()
    var age = Int()
    var phone: String!
    var gender = String()
    var sexYouLike = String()
    var genderPicker = UIPickerView()
    var user: User?
    
    let myPickerData = [String](arrayLiteral: "", "Male", "Female", "All Humans")
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        genderPicker.delegate = self
        initializeUI()
    }
    
    // MARK: - Logic
    
    @objc private func handleDone() {
        guard genderTF.text != "" else {
            errorLabel.isHidden = false
            return
        }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        self.sexYouLike = self.genderTF.text ?? ""
        let photoCnotroller = BioController()
        let docData: [String: Any] = ["Gender-Preference": self.sexYouLike]
        Firestore.firestore().collection("users").document(uid).setData(docData, merge: true)
        photoCnotroller.modalPresentationStyle = .fullScreen
        self.present(photoCnotroller, animated: true)
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
        genderTF.text = myPickerData[row]
        
    }
    
    // MARK: - User Interface
    
    private func initializeUI() {
         view.backgroundColor = .white
                   genderPicker.delegate = self
                   genderTF.text = user?.gender ?? ""
                  genderTF.inputView = genderPicker
             
                   view.addSubview(label)
                   label.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                       leading: view.leadingAnchor,
                                       bottom: nil,
                                       trailing: view.trailingAnchor,
                                       padding: .init(top: 12, left: 30, bottom: 0, right: 30))
                          
                        view.addSubview(genderTF)
                   genderTF.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: view.bounds.height/5, left: 30, bottom: 0, right: 30))
                        
                        view.addSubview(underline)
                   underline.anchor(top: genderTF.bottomAnchor, leading: genderTF.leadingAnchor, bottom: nil, trailing: genderTF.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
                   
                        view.addSubview(doneButton)
                   doneButton.anchor(top: underline.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 20, left: 120, bottom: 0, right: 120))
                          
                          view.addSubview(errorLabel)
                          errorLabel.isHidden = true
                          errorLabel.anchor(top: doneButton.bottomAnchor,
                                            leading: view.leadingAnchor,
                                            bottom: nil,
                                            trailing: view.trailingAnchor,
                                            padding: .init(top: 40, left: 20, bottom: 0, right: 20))
                   // Do any additional setup after loading the view.
    }
    
    private let genderTF: UITextField = {
        let tf = GenderTextField()
        tf.placeholder = "Select"
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 15
        tf.font = UIFont.systemFont(ofSize: 25)
        tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        return tf
    }()
    
    private let underline: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 4).isActive = true
        view.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.6713966727, alpha: 1)
        return view
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Select Sex Preference"
        label.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        return label
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Please select a preference"
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
