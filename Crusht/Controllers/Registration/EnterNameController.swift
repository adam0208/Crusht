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
//    var user: User?
//    var phone: String!
//    var name = String()
//
//    // MARK: - Life Cycle Methods
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        nameTF.delegate = self
//        initializeUI()
//    }
//
//    // MARK: - Logic
//
//    @objc private func handleDone() {
//        guard nameTF.text != "" else {
//            errorLabel.isHidden = false
//            return
//        }
//        let birthdayController = BirthdayController()
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//        let docData: [String: Any] = ["Full Name": nameTF.text ?? ""]
//        Firestore.firestore().collection("users").document(uid).setData(docData, merge: true)
//        birthdayController.modalPresentationStyle = .fullScreen
//        self.present(birthdayController, animated: true)
//    }
//
//    // MARK: - UITextFieldDelegate
//    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let maxLength = 40
//        let currentString: NSString = textField.text! as NSString
//        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
//        return newString.length <= maxLength
//    }
//
//    // MARK: - User Interface
//
//    private func initializeUI() {
//        view.addGradientSublayer()
//
//        let stack = UIStackView(arrangedSubviews: [nameTF, doneButton])
//        view.addSubview(stack)
//        stack.axis = .vertical
//        view.addSubview(label)
//        label.anchor(top: view.safeAreaLayoutGuide.topAnchor,
//                     leading: view.leadingAnchor,
//                     bottom: nil,
//                     trailing: view.trailingAnchor,
//                     padding: .init(top: view.bounds.height / 5, left: 30, bottom: 0, right: 30))
//
//        stack.anchor(top: label.bottomAnchor,
//                     leading: view.leadingAnchor,
//                     bottom: view.safeAreaLayoutGuide.bottomAnchor,
//                     trailing: view.trailingAnchor,
//                     padding: .init(top: 4, left: 30, bottom: view.bounds.height / 2.2, right: 30))
//
//        stack.spacing = 20
//        view.addSubview(errorLabel)
//        errorLabel.isHidden = true
//        errorLabel.anchor(top: stack.bottomAnchor,
//                          leading: view.leadingAnchor,
//                          bottom: nil,
//                          trailing: view.trailingAnchor,
//                          padding: .init(top: 40, left: 20, bottom: 0, right: 20))
//    }
//
//    private let nameTF: UITextField = {
//        let tf = NameTextField()
//        tf.placeholder = "Full Name"
//        tf.backgroundColor = .white
//        tf.layer.cornerRadius = 15
//        tf.font = UIFont.systemFont(ofSize: 25)
//        tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
//
//        return tf
//    }()
//
//    private let label: UILabel = {
//        let label = UILabel()
//        label.text = "Enter Your Full Name"
//        label.textColor = .white
//        label.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
//        label.textAlignment = .center
//        label.adjustsFontSizeToFitWidth = true
//
//        return label
//    }()
//
//    private let errorLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Please enter your name"
//        label.textColor = .white
//        label.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
//        label.textAlignment = .center
//        label.adjustsFontSizeToFitWidth = true
//
//        return label
//    }()
//
//    private let doneButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Next", for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
//        button.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
//        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
//        button.titleLabel?.adjustsFontForContentSizeCategory = true
//        button.layer.cornerRadius = 22
//        button.addTarget(self, action: #selector(handleDone), for: .touchUpInside)
//
//        return button
//    }()
    
      var user: User?
        
        //UI
        
        let firstNameTF: UITextField = {
            let tf = UITextField()
            tf.backgroundColor = .clear
            tf.attributedPlaceholder =  NSAttributedString(string: "First Name", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
            tf.textColor = .black
            tf.textAlignment = .left
            tf.font = UIFont.systemFont(ofSize: 40, weight: .bold)
            return tf
        }()
        
        let lastNameTF: UITextField = {
            let tf = UITextField()
            tf.backgroundColor = .clear
            tf.attributedPlaceholder =  NSAttributedString(string: "Last Name", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
            tf.textColor = .black
            tf.textAlignment = .left
            tf.font = UIFont.systemFont(ofSize: 40, weight: .bold)
            return tf
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
        
        private let label: UILabel = {
            let label = UILabel()
            label.text = "Enter Your Name"
            label.textColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
            label.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            
            return label
        }()
        
        private let errorLabel: UILabel = {
            let label = UILabel()
            label.text = "Enter Your Name"
            label.textColor = .black
            label.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            
            return label
        }()
        
        private let saveButton: UIButton = {
               let button = UIButton(type: .system)
               button.setTitle("Next", for: .normal)
               button.setTitleColor(.white, for: .normal)
               button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
               button.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
               button.heightAnchor.constraint(equalToConstant: 44).isActive = true
               button.widthAnchor.constraint(equalToConstant: 60).isActive = true
               button.titleLabel?.adjustsFontForContentSizeCategory = true
               button.layer.cornerRadius = 18
               button.addTarget(self, action: #selector(handleDone), for: .touchUpInside)
               
               return button
           }()
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.navigationController?.navigationBar.isHidden = true
        }
     

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .white
           
            firstNameTF.text = user?.firstName ?? ""
            lastNameTF.text = user?.lastName ?? ""
      
            view.addSubview(label)
            label.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                leading: view.leadingAnchor,
                                bottom: nil,
                                trailing: view.trailingAnchor,
                                padding: .init(top: 12, left: 30, bottom: 0, right: 30))
                   
                 view.addSubview(firstNameTF)
            firstNameTF.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: view.bounds.height/5, left: 30, bottom: 0, right: 30))
                 
                 view.addSubview(underline)
            underline.anchor(top: firstNameTF.bottomAnchor, leading: firstNameTF.leadingAnchor, bottom: nil, trailing: firstNameTF.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
            
            view.addSubview(lastNameTF)
            lastNameTF.anchor(top: underline.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 12, left: 30, bottom: 0, right: 30))
                        
                        view.addSubview(underline2)
            underline2.anchor(top: lastNameTF.bottomAnchor, leading: lastNameTF.leadingAnchor, bottom: nil, trailing: lastNameTF.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
                 
                 view.addSubview(saveButton)
            saveButton.anchor(top: underline2.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 20, left: 120, bottom: 0, right: 120))
                   
                   view.addSubview(errorLabel)
                   errorLabel.isHidden = true
                   errorLabel.anchor(top: saveButton.bottomAnchor,
                                     leading: view.leadingAnchor,
                                     bottom: nil,
                                     trailing: view.trailingAnchor,
                                     padding: .init(top: 40, left: 20, bottom: 0, right: 20))
            // Do any additional setup after loading the view.
        }
        
        //Functions

        @objc fileprivate func handleDone() {
            guard firstNameTF.text != "" else {
                errorLabel.isHidden = false
                return
            }
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let docData: [String: Any] = ["First Name": firstNameTF.text ?? "",
                                          "Last Name": lastNameTF.text ?? ""]
            Firestore.firestore().collection("users").document(uid).setData(docData, merge: true)
                    let birthdayController = BirthdayController()
                    birthdayController.modalPresentationStyle = .fullScreen
                    self.present(birthdayController, animated: true)
        }
        
        @objc fileprivate func handleBack() {
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.popViewController(animated: true)
        }
    }

