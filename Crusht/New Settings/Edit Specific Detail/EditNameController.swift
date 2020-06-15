//
//  EditNameController.swift
//  Crusht
//
//  Created by William Kelly on 6/13/20.
//  Copyright © 2020 William Kelly. All rights reserved.
//

import UIKit
import Firebase

class EditNameController: UIViewController {
    
    var user: User?
    
    //UI
    
    let firstNameTF: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .clear
        tf.textColor = .white
        tf.textAlignment = .left
        tf.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        return tf
    }()
    
    let lastNameTF: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .clear
        tf.textColor = .white
        tf.textAlignment = .left
        tf.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        return tf
    }()
    
    let underline: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 4).isActive = true
        view.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.6713966727, alpha: 1)
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
        label.text = "Your Name"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
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
    
    private let saveButton: UIButton = {
           let button = UIButton(type: .system)
           button.setTitle("Save", for: .normal)
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
    
    let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "icons8-back-filled-30-2").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
 

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGradientSublayer()
       
        firstNameTF.text = user?.name ?? "Enter Name"
        lastNameTF.text = "Kelly"
  
        view.addSubview(label)
        label.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                            leading: view.leadingAnchor,
                            bottom: nil,
                            trailing: view.trailingAnchor,
                            padding: .init(top: 12, left: 30, bottom: 0, right: 30))
        
        view.addSubview(backButton)
        backButton.anchor(top: label.topAnchor, leading: view.leadingAnchor, bottom: label.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 6, bottom: 0, right: 0))
               
             view.addSubview(firstNameTF)
        firstNameTF.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: view.bounds.height/5, left: 30, bottom: 0, right: 30))
             
             view.addSubview(underline)
        underline.anchor(top: firstNameTF.bottomAnchor, leading: firstNameTF.leadingAnchor, bottom: nil, trailing: firstNameTF.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        
        view.addSubview(lastNameTF)
        lastNameTF.anchor(top: underline.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 12, left: 30, bottom: 0, right: 30))
                    
                    view.addSubview(underline2)
        underline2.anchor(top: lastNameTF.bottomAnchor, leading: lastNameTF.leadingAnchor, bottom: nil, trailing: lastNameTF.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
             
             view.addSubview(saveButton)
        saveButton.anchor(top: underline2.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 20, left: 80, bottom: 0, right: 80))
               
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
                                      "Last Name": firstNameTF.text ?? ""]
        Firestore.firestore().collection("users").document(uid).setData(docData, merge: true)
        self.dismiss(animated: true)
    }
    
    @objc fileprivate func handleBack() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.popToRootViewController(animated: true)
    }
}
