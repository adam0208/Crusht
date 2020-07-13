//
//  EditOccupationController.swift
//  Crusht
//
//  Created by William Kelly on 6/15/20.
//  Copyright © 2020 William Kelly. All rights reserved.
//

import UIKit
import Firebase

class EditOccupationController: UIViewController {
    //NEED TO ADD A DID SAVE SETTINGS DELAGATE TO THESE
    
        var user: User?
        var madeChange = false
        var delegate: SettingsControllerDelegate?
        //UI
        
        let occupationTF: UITextField = {
            let tf = UITextField()
            tf.backgroundColor = .clear
            tf.textColor = .black
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
        
        private let label: UILabel = {
            let label = UILabel()
            label.text = "Your Occupation"
            label.textColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
            label.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            
            return label
        }()
        
        private let errorLabel: UILabel = {
            let label = UILabel()
            label.text = "Please enter your occupation"
            label.textColor = .black
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
               button.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
               button.heightAnchor.constraint(equalToConstant: 44).isActive = true
               button.widthAnchor.constraint(equalToConstant: 60).isActive = true
               button.titleLabel?.adjustsFontForContentSizeCategory = true
               button.layer.cornerRadius = 18
               button.addTarget(self, action: #selector(handleDone), for: .touchUpInside)
               
               return button
           }()
        
        let backButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "icons8-chevron-left-30").withRenderingMode(.alwaysOriginal), for: .normal)
            button.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
            return button
        }()
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.navigationController?.navigationBar.isHidden = true
        }
     

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .white
           
            occupationTF.text = user?.occupation ?? ""
      
            view.addSubview(label)
            label.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                leading: view.leadingAnchor,
                                bottom: nil,
                                trailing: view.trailingAnchor,
                                padding: .init(top: 12, left: 30, bottom: 0, right: 30))
            
            view.addSubview(backButton)
            backButton.anchor(top: label.topAnchor, leading: view.leadingAnchor, bottom: label.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 6, bottom: 0, right: 0))
                   
                 view.addSubview(occupationTF)
            occupationTF.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: view.bounds.height/5, left: 30, bottom: 0, right: 30))
                 
                 view.addSubview(underline)
            underline.anchor(top: occupationTF.bottomAnchor, leading: occupationTF.leadingAnchor, bottom: nil, trailing: occupationTF.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
            
                 view.addSubview(saveButton)
            saveButton.anchor(top: underline.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 20, left: 120, bottom: 0, right: 120))
                   
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
            guard occupationTF.text != "" else {
                errorLabel.isHidden = false
                return
            }
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let docData: [String: Any] = ["Occupation": occupationTF.text ?? ""]
            Firestore.firestore().collection("users").document(uid).setData(docData, merge: true)
            madeChange = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.errorLabel.text = "Saving..."
                self.errorLabel.isHidden = false
                self.handleBack()
            }
        }
        
    @objc fileprivate func handleBack() {
           
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.popViewController(animated: true) {
                if self.madeChange == true {
            self.delegate?.didSaveSettings()
            }
        }
    }
}

extension UINavigationController {
    
    func pushViewController(_ viewController: UIViewController, animated: Bool = true, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
    func popViewController(animated: Bool = true, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popViewController(animated: animated)
        CATransaction.commit()
    }
    
    func popToRootViewController(animated: Bool = true, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popToRootViewController(animated: animated)
        CATransaction.commit()
    }
}
