//
//  ReportControllerViewController.swift
//  Crusht
//
//  Created by William Kelly on 3/29/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase

class ReportControllerViewController: UIViewController {
    
    var reports: Reports?
    
    var reportUID = String()
    
    var reportName = String()
    
    var reportEmail = String()
    
    var reportPhoneNumebr = String()
    
    //this is the id of the person who is making the accusation
    var uid = String()
    
    let textView: UITextView = {
        let tv = ReportTextView()
        tv.font = UIFont.systemFont(ofSize: 25)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let myBackButton = UIBarButtonItem()
        myBackButton.title = "👈"
        navigationItem.backBarButtonItem = myBackButton
    }

 lazy var stackView = UIStackView(arrangedSubviews: [textView, reportBttn])
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        // navigationItem.backBarButtonItem?.title = "👈"
        setupNotificationObservers()
        setupTapGesture()
        navigationItem.title = "Report User"
        setupGradientLayer()
        textView.text = "Please tell us why you are reporting this user. We take these accusations seriously."
        textView.textColor = UIColor.lightGray
       
        view.addSubview(stackView)
        stackView.axis = .vertical
        
        stackView.spacing = 16
        
        stackView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 100, left: 20, bottom: 400, right: 20))
        
    }
    
    @objc fileprivate func reportUser() {
        
        let docData: [String: Any] = ["uid": reportUID,
                                      "offender-name": reportName,
                                      "email": reportEmail,
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
                                                      "email": self.reportEmail,
                                                      "text": self.textView.text,
                                                      "reporter-uid": self.uid,
                                                     "number-of-reports": (self.reports?.reportNumber)! + 1
                    ]
                    Firestore.firestore().collection("reported").document(self.reportUID).collection("user-reports").addDocument(data: newDocData)
                })
            }
        }
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //NotificationCenter.default.removeObserver(self) // Comment out to proper keyboard
        
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
        print(keyboardFrame)
        
        // let's try to figure out how tall the gap is from the register button to the bottom of the screen
        let bottomSpace = view.frame.height - stackView.frame.origin.y - stackView.frame.height
        print(bottomSpace)
        
        let difference = keyboardFrame.height - bottomSpace
        self.view.transform = CGAffineTransform(translationX: 0, y: -difference - 8)
    }
    

}

class ReportTextView: UITextView, UITextViewDelegate {
    
    func adjustUITextViewHeight(arg : UITextView)
    {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = false
    }
    override var intrinsicContentSize: CGSize {
        return .init(width: 0, height: 100)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Placeholder"
            textView.textColor = UIColor.lightGray
        }
    }
    
    
    
}





