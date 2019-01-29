//
//  TransitionCrushesController.swift
//  Crusht
//
//  Created by William Kelly on 1/21/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit

class TransitionCrushesController: UIViewController {
    
    let Text: UILabel = {
        let label = UILabel()
        
        label.text = "Find Crushes Via..."
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    let findCrushesThroughContacts: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("From your Contacts", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100)
        
        button.layer.cornerRadius = 22
        
        button.addTarget(self, action: #selector(handleContacts), for: .touchUpInside)
        return button
    }()
    
    let findCrushesThroughSchool: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("From Your School", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 0, alpha: 1)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100)
        
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
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100)
        
        button.layer.cornerRadius = 22
        
        button.addTarget(self, action: #selector(handleFacebook), for: .touchUpInside)
        return button
    }()
    
    let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
        button.addTarget(self, action: #selector(handleBack), for: .touchUpInside)

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupGradientLayer()
        
        let stack = UIStackView(arrangedSubviews: [Text, findCrushesThroughContacts,findCrushesThroughSchool,findCrushesThroughFacebook])
        view.addSubview(stack)
        view.addSubview(backButton)
        
        stack.axis = .vertical
        
        stack.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 180, left: 30, bottom: 180, right: 30))
        
        stack.spacing = 20
        
        backButton.anchor(top: nil, leading: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil)
        
    }
    
    @objc fileprivate func handleContacts() {
        let contactsController = FindCrushesTableViewController()
        let navigationController = UINavigationController(rootViewController: contactsController)
        present(navigationController, animated: true)
    }
    
    @objc fileprivate func handleSchool() {
        let schoolController = SchoolCrushController()
        let navigationController = UINavigationController(rootViewController: schoolController)
        present(navigationController, animated: true)
    }
    
    @objc fileprivate func handleFacebook() {
        let fbcontroller = FacebookCrushController()
        let navigationController = UINavigationController(rootViewController: fbcontroller)
        present(navigationController, animated: true)
    }
    
    @objc fileprivate func handleBack() {
        let profileController = ProfilePageViewController()
        present(profileController, animated: true)
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



