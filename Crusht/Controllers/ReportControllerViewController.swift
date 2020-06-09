//
//  ReportControllerViewController.swift
//  Crusht
//
//  Created by William Kelly on 3/29/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class ReportControllerViewController: UIViewController {
    
    var reports: Reports?
    var reportUID = String()
    var reportName = String()
    var reportPhone = String()
    var reportPhoneNumebr = String()
    var uid = String() // This is the id of the person who is making the accusation
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotificationObservers()
        setupTapGesture()
        initializeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Logic
    
    @objc fileprivate func reportUser() {
        hudLabel.isHidden = false
        let docData: [String: Any] = ["uid": reportUID,
                                      "offender-name": reportName,
                                      "phone": reportPhoneNumebr,
                                      "text": textView.text,
                                      "reporter-uid": uid,
                                      "number-of-reports": 1
                                    ]
        
        Firestore.firestore().collection("reported").whereField("uid", isEqualTo: reportUID).getDocuments { (snapshot, err) in
            if let err = err {
                print(err)
            }
            
            if (snapshot?.isEmpty)! {
                Firestore.firestore().collection("reported").document(self.reportUID).setData(docData)
            }
            else {
                Firestore.firestore().collection("reported").document(self.reportUID).getDocument(completion: { (snapshot, err) in
                    if let err = err {
                        print(err)
                    }
                    guard let data = snapshot?.data() else {return}
                    self.reports = Reports(dictionary: data)
                    let newDocData: [String: Any] = [ "uid": self.reportUID,
                                                      "offender-name": self.reportName,
                                                      "phone": self.reportPhoneNumebr,
                                                      "text": self.textView.text,
                                                      "reporter-uid": self.uid,
                                                      "number-of-reports": (self.reports?.reportNumber)! + 1
                                                     ]
                    Firestore.firestore().collection("reported").document(self.reportUID).collection("user-reports").addDocument(data: newDocData)
                })
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
           self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    fileprivate func setupTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
    }
    
    @objc fileprivate func handleTapDismiss() {
        self.view.endEditing(true)
    }
    
    fileprivate func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc fileprivate func handleKeyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.transform = .identity
        })
    }
    
    @objc fileprivate func handleKeyboardShow(notification: Notification) {
        // How to figure out how tall the keyboard actually is
        guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.cgRectValue
        
        // Let's try to figure out how tall the gap is from the register button to the bottom of the screen
        let bottomSpace = view.frame.height - stackView.frame.origin.y - (stackView.frame.height + 30)
        
        let difference = keyboardFrame.height - bottomSpace
        self.view.transform = CGAffineTransform(translationX: 0, y: -difference - 8)
    }
    
    // MARK: - User Interface
    
    private func initializeUI() {
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Report \(reportName)"
        view.addGradientSublayer()
        navigationController?.navigationBar.prefersLargeTitles = false

        view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 14
        stackView.anchor(top: view.topAnchor,
                         leading: view.leadingAnchor,
                         bottom: view.bottomAnchor,
                         trailing: view.trailingAnchor,
                         padding: .init(top: view.bounds.height / 10, left: view.bounds.width / 9, bottom: view.bounds.height / 3, right: view.bounds.width / 9))
        
        view.addSubview(hudLabel)
        hudLabel.isHidden = true
        hudLabel.anchor(top: stackView.bottomAnchor,
                        leading: view.leadingAnchor,
                        bottom: nil,
                        trailing: view.trailingAnchor,
                        padding: .init(top: 5, left: 20, bottom: 0, right: 20))
    }
    
    lazy var stackView = UIStackView(arrangedSubviews: [reportLabel, textView, reportBttn])

    let reportLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
         label.textColor = .white
        label.text = "Please tell us why you are reporting this user. We take these accusations seriously. We will review your report within 24 hours."
        label.numberOfLines = 0
        return label
    }()
    
    let hudLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.text = "Processing..."
        label.numberOfLines = 0
        return label
    }()
    
    
    let textView: UITextView = {
        let tv = ReportTextView()
        tv.font = UIFont.systemFont(ofSize: 18)
         tv.textColor = .black
        tv.layer.cornerRadius = 18
        tv.clipsToBounds = true
        
        tv.adjustsFontForContentSizeCategory = true
        return tv
    }()
    
    let reportBttn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Report", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 200) .isActive = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(reportUser), for: .touchUpInside)
        return button
    }()
}
