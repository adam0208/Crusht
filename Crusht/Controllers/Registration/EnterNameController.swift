//
//  EnterNameController.swift
//  Crusht
//
//  Created by William Kelly on 4/14/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class EnterNameController: UIViewController, UITextFieldDelegate {
    var user: User?
    var phone: String!
    var name = String()
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTF.delegate = self
        initializeUI()
    }
    
    // MARK: - Logic
    
    @objc private func handleDone() {
        guard nameTF.text != "" else {
            errorLabel.isHidden = false
            return
        }
        let birthdayController = BirthdayController()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let docData: [String: Any] = ["Full Name": nameTF.text ?? ""]
        Firestore.firestore().collection("users").document(uid).setData(docData, merge: true)
        birthdayController.modalPresentationStyle = .fullScreen
        self.present(birthdayController, animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 40
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    // MARK: - User Interface
    
    private func initializeUI() {
        view.addGradientSublayer()
        
        let stack = UIStackView(arrangedSubviews: [nameTF, doneButton])
        view.addSubview(stack)
        stack.axis = .vertical
        view.addSubview(label)
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
        view.addSubview(errorLabel)
        errorLabel.isHidden = true
        errorLabel.anchor(top: stack.bottomAnchor,
                          leading: view.leadingAnchor,
                          bottom: nil,
                          trailing: view.trailingAnchor,
                          padding: .init(top: 40, left: 20, bottom: 0, right: 20))
    }
    
    private let nameTF: UITextField = {
        let tf = NameTextField()
        tf.placeholder = "Full Name"
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 15
        tf.font = UIFont.systemFont(ofSize: 25)
        tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        return tf
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Enter Your Full Name"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter your name"
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
