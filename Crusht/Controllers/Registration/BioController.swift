//
//  BioController.swift
//  Crusht
//
//  Created by William Kelly on 4/14/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase

class BioController: UIViewController, UITextViewDelegate {
    var user: User?
    var name = String()
    var birthday = String()
    var bio = String()
    var school = String()
    var age = Int()
    var phone: String!
    var gender = String()
    var sexYouLike = String()
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
    }
    
    // MARK: - Logic
    
    @objc private func handleDone() {
        guard bioTF.text != "" else {
            errorLabel.isHidden = false
            return
        }
        DispatchQueue.main.async {
            self.bio = self.bioTF.text
            let enterSexController = EnterPhotoController()
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let docData: [String: Any] = ["Bio": self.bio]
            Firestore.firestore().collection("users").document(uid).setData(docData, merge: true)
            self.present(enterSexController, animated: true)
        }
    }
    
    // MARK: - UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 300 chars restriction
        return bioTF.text.count + (text.count - range.length) <= 500
    }

    // MARK: - User Interface
    
    private func initializeUI() {
        view.addGradientSublayer()
        let stack = UIStackView(arrangedSubviews: [bioTF, doneButton])
        view.addSubview(stack)
        stack.axis = .vertical
        view.addSubview(label)
        label.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                     leading: view.leadingAnchor,
                     bottom: nil, trailing: view.trailingAnchor,
                     padding: .init(top: view.bounds.height / 5, left: 30, bottom: 0, right: 30))
        
        stack.anchor(top: label.bottomAnchor,
                     leading: view.leadingAnchor,
                     bottom: view.safeAreaLayoutGuide.bottomAnchor,
                     trailing: view.trailingAnchor,
                     padding: .init(top: 10, left: 30, bottom: view.bounds.height / 2.2, right: 30))
        
        stack.spacing = 20
        view.addSubview(errorLabel)
        errorLabel.isHidden = true
        errorLabel.anchor(top: stack.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 40, left: 20, bottom: 0, right: 20))
    }
    
    private let bioTF: UITextView = {
        let tf = ReportTextView()
        tf.font = UIFont.systemFont(ofSize: 20)
        tf.adjustsFontForContentSizeCategory = true
        tf.text = ""
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 14
        tf.clipsToBounds = true
        
        return tf
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Enter Your Bio Below"
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        
        return label
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter your bio"
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
