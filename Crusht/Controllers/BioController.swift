//
//  BioController.swift
//  Crusht
//
//  Created by William Kelly on 4/14/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import JGProgressHUD

class BioController: UIViewController {

    let bioTF: UITextView = {
        let tf = ReportTextView()
        tf.font = UIFont.systemFont(ofSize: 20)
        tf.adjustsFontForContentSizeCategory = true
        tf.text = ""
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 14
        tf.clipsToBounds = true
        return tf
    }()
    
    let label: UILabel = {
        let label = UILabel()
        
        label.text = "Enter Your Bio Below"
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        
        label.textColor = .black
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
    
    let hud = JGProgressHUD(style: .dark)
    
    @objc fileprivate func handleDone() {
        if bioTF.text == "" {
            hud.textLabel.text = "Please enter your bio"
            hud.show(in: view)
            hud.dismiss(afterDelay: 2)
            return
        }
        else {
            bio = bioTF.text
            
            let enterSexController = YourSexController()
            enterSexController.age = age
            enterSexController.name = name
            enterSexController.birthday = birthday
            enterSexController.bio = bio
            enterSexController.school = school
            enterSexController.phone = phone
            present(enterSexController, animated: true)
            
        }
        
    }
    
    var user: User?
    
    var name = String()
    var birthday = String()
    var bio = String()
    var school = String()
    var age = Int()
    var phone = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGradientLayer()
        
        let stack = UIStackView(arrangedSubviews: [bioTF, doneButton])
        view.addSubview(stack)
        
        stack.axis = .vertical
        
        view.addSubview(label)
        
        label.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: view.bounds.height/5, left: 30, bottom: 0, right: 30))
        
        stack.anchor(top: label.bottomAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 10, left: 30, bottom: view.bounds.height/2.2, right: 30))
        
        stack.spacing = 20
        
        
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
