//
//  TransitionCrushesController.swift
//  Crusht
//
//  Created by William Kelly on 1/21/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class TransitionCrushesController: UIViewController {
    
//    var user: User?
//
//    fileprivate func fetchCurrentUser() {
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
//            if let err = err {
//                print(err)
//                return
//            }
//            guard let dictionary = snapshot?.data() else {return}
//            self.user = User(dictionary: dictionary)
//        }
//    }
    
    let Text: UILabel = {
        let label = UILabel()
        
        label.text = "Find Crushes Via..."
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true

        label.textColor = .black
        return label
    }()
    
    let privacyText: UILabel = {
        let label = UILabel()
        
        label.text = "If one of your contacts doesn't have the app, an annonomous message will be sent to their device informing them that \"someone\" has a crush on them."
        label.font = UIFont.systemFont(ofSize: 24, weight: .light)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        
        label.textColor = .black
        return label
    }()
    
    let findCrushesThroughContacts: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Your Contacts", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100)
        button.titleLabel?.adjustsFontForContentSizeCategory = true

        
        button.layer.cornerRadius = 22
        
        button.addTarget(self, action: #selector(handleContacts), for: .touchUpInside)
        return button
    }()
    
    let findCrushesThroughSchool: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Your School", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        
        button.layer.cornerRadius = 22
        
        button.addTarget(self, action: #selector(handleSchool), for: .touchUpInside)
        return button
    }()
    
    let findCrushesThroughFacebook: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Facebook Friends", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        button.titleLabel?.adjustsFontSizeToFitWidth = true

        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100)
        button.titleLabel?.adjustsFontForContentSizeCategory = true

        
        button.layer.cornerRadius = 22
        
        button.addTarget(self, action: #selector(handleFacebook), for: .touchUpInside)
        return button
    }()
    
    let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("👈", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 50, weight: .heavy)
        button.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        button.titleLabel?.adjustsFontForContentSizeCategory = true


        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        //fetchCurrentUser()
        setupGradientLayer()
        navigationController?.isNavigationBarHidden = true
        let stack = UIStackView(arrangedSubviews: [Text, findCrushesThroughContacts,findCrushesThroughSchool,findCrushesThroughFacebook, privacyText])
        view.addSubview(stack)
        view.addSubview(backButton)
        
        stack.axis = .vertical
        
        let padding = view.bounds.height/5
        
        stack.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: padding, left: 30, bottom: padding, right: 30))
        
        stack.spacing = 20
        
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: -20, left: 20, bottom: 0, right: 0))
    }
    
    @objc fileprivate func handleContacts() {
        let contactsController = FindCrushesTableViewController()
        navigationController?.pushViewController(contactsController, animated: true)
    }
    
    @objc fileprivate func handleSchool() {
        let schoolController = SchoolCrushController()
        navigationController?.pushViewController(schoolController, animated: true)
    }
    
    @objc fileprivate func handleFacebook() {
        
        let fbcontroller = FacebookCrushController()
        navigationController?.pushViewController(fbcontroller, animated: true)
        
    }
    
    @objc fileprivate func handleBack() {
      self.dismiss(animated: true)
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



