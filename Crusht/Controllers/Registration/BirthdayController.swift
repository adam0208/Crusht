//
//  BirthdayController.swift
//  Crusht
//
//  Created by William Kelly on 4/14/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase

class BirthdayController: UIViewController {
    var user: User?
    var phone: String!
    var name = String()
    var birthday = String()
    var age = Int()
    var datepicker = UIDatePicker()
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
    }
    
    // MARK: - Logic
    
    @objc private func donedatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        ageTextField.text = formatter.string(from: datepicker.date)
        self.view.endEditing(true)
    }
    
    @objc private func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    @objc private func dateChanged() {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: datepicker.date)
        if let day = components.day, let month = components.month, let year = components.year {
            ageTextField.text = "\(month)-\(day)-\(year)"
        }
    }
    
    private func calcAge(birthday: String) -> Int {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM/dd/yyyy"
        let birthdayDate = dateFormater.date(from: birthday)
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
        let now = Date()
        let calcAge = (calendar.components(.year, from: birthdayDate ?? dateFormater.date(from: "10-31-1995")!, to: now, options: []))
        let age = calcAge.year
        return age!
    }
    
    @objc private func handleDone() {
        let bday = ageTextField.text?.replacingOccurrences(of: "/", with: "-")
        birthday = bday ?? "10-30-1999"
        age = calcAge(birthday: birthday)
        
        guard ageTextField.text != "" else {
            errorLabel.isHidden = false
            return
        }
        guard age >= 18 else {
            errorLabel.text = "Must be 18 or older to join"
            return
        }
        
        let enterSchoolController = EnterSchoolController()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let docData: [String: Any] = ["Birthday": birthday, "Age": age]
        Firestore.firestore().collection("users").document(uid).setData(docData, merge: true)
        enterSchoolController.modalPresentationStyle = .fullScreen
        present(enterSchoolController, animated: true)
    }
    
    @objc private func handleTapDismiss() {
        donedatePicker() // Make sure date is saved
        self.view.endEditing(true) // Dismisses keyboard
    }
    
    // MARK: - User Interface
    
    private func initializeUI() {
        datepicker.datePickerMode = .date
        ageTextField.inputView = datepicker
        
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        ageTextField.inputAccessoryView = toolbar
        
        view.addGradientSublayer()
        
        let stack = UIStackView(arrangedSubviews: [ageTextField, doneBttn])
        view.addSubview(stack)
        stack.axis = .vertical
        view.addSubview(label)
        label.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                     leading: view.leadingAnchor,
                     bottom: nil,
                     trailing: view.trailingAnchor,
                     padding: .init(top: view.bounds.height / 5, left: 30, bottom: 0, right: 30))
        
        stack.anchor(top: label.bottomAnchor,
                     leading: view.leadingAnchor,
                     bottom: view.safeAreaLayoutGuide.bottomAnchor,
                     trailing: view.trailingAnchor,
                     padding: .init(top: 4, left: 30, bottom: view.bounds.height / 2.2, right: 30))
        
        stack.spacing = 20
        
        view.addSubview(errorLabel)
        errorLabel.isHidden = true
        errorLabel.anchor(top: stack.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 40, left: 20, bottom: 0, right: 20))
    }
    
    private let ageTextField: UITextField = {
        let tf = NameTextField()
        tf.placeholder = "Birthday"
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 15
        tf.font = UIFont.systemFont(ofSize: 25)
        tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        return tf
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Enter your Birthday"
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.textAlignment = .center
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Please enter your birthday"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    
    private let doneBttn: UIButton = {
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
