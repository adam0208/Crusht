//
//  MessageReportController.swift
//  Crusht
//
//  Created by William Kelly on 4/6/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class MessageReportController: UIViewController {

    var reports: Reports?
    
    var reportUID = String()
    
    var reportName = String()
    
    var reportPhone = String()
    
    var reportPhoneNumebr = String()
    
    //this is the id of the person who is making the accusation
    var uid = String()
    
    let reportLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
         label.textColor = .white
        label.text = "Please tell us why you are reporting this user. We take these accusations seriously."
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
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //
    //        let myBackButton = UIBarButtonItem()
    //        myBackButton.title = "👈"
    //        navigationItem.backBarButtonItem = myBackButton
    //    }
    
    lazy var stackView = UIStackView(arrangedSubviews: [reportLabel, textView, reportBttn])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = false
        setupNotificationObservers()
        setupTapGesture()
        navigationItem.title = "Report \(reportName)"
        setupGradientLayer()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        view.addSubview(stackView)
        stackView.axis = .vertical
        
        stackView.spacing = 14
        
      stackView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: view.bounds.height/10, left: view.bounds.width/9, bottom: view.bounds.height/3, right: view.bounds.width/9))
        
    }
    
    let hud = JGProgressHUD(style: .dark)
    
    @objc fileprivate func reportUser() {
        hud.textLabel.text = "Thank you for reporting this user, we will process your request"
        hud.show(in: navigationController!.view)
        
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
        hud.dismiss(afterDelay: 4)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.1) {
              self.dismiss(animated: true)
        }
      
    }
    
    let gradientLayer = CAGradientLayer()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.bounds
        
    }
    
    fileprivate func setupGradientLayer() {
        
        let topColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        let bottomColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
        // make sure to user cgColor
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0, 1]
        view.layer.addSublayer(gradientLayer)
        gradientLayer.frame = view.bounds
    }
    
    fileprivate func setupTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
    }
    
    @objc fileprivate func handleTapDismiss() {
        self.view.endEditing(true) // dismisses keyboard
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
        // how to figure out how tall the keyboard actually is
        guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.cgRectValue
        
        // let's try to figure out how tall the gap is from the register button to the bottom of the screen
        let bottomSpace = view.frame.height - stackView.frame.origin.y - stackView.frame.height
        
        let difference = keyboardFrame.height - bottomSpace
        self.view.transform = CGAffineTransform(translationX: 0, y: -difference - 8)
    }
    
    
}





