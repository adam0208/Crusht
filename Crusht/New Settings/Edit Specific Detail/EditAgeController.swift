//
//  EditAgeController.swift
//  Crusht
//
//  Created by William Kelly on 6/26/20.
//  Copyright © 2020 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class EditAgeController: UIViewController {
    
    //Variables
    
    var user: User?
    var birthday = String()
    var datepicker = UIDatePicker()
    var age = Int()
        
        // MARK: - Life Cycle Methods
        
        override func viewDidLoad() {
            super.viewDidLoad()
            initializeUI()
        }
    
       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           self.navigationController?.navigationBar.isHidden = true
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
    
    let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "icons8-chevron-left-30").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        return button
    }()
        
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
            
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let docData: [String: Any] = ["Birthday": birthday, "Age": age]
            Firestore.firestore().collection("users").document(uid).setData(docData, merge: true)
            self.handleBack()
        }
    
        @objc private func handleTapDismiss() {
            donedatePicker() // Make sure date is saved
            self.view.endEditing(true) // Dismisses keyboard
        }
    
    @objc fileprivate func handleBack() {
         self.navigationController?.navigationBar.isHidden = false
         self.navigationController?.navigationBar.prefersLargeTitles = true
         self.navigationController?.popViewController(animated: true)
     }
        
        // MARK: - User Interface
        
        private func initializeUI() {
            view.backgroundColor = .white
            datepicker.datePickerMode = .date
            ageTextField.inputView = datepicker
            ageTextField.text = user?.birthday
            
            let toolbar = UIToolbar();
            toolbar.sizeToFit()
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
            let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
            toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
            
            ageTextField.inputAccessoryView = toolbar
                    
            view.addSubview(label)
            label.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                leading: view.leadingAnchor,
                                bottom: nil,
                                trailing: view.trailingAnchor,
                                padding: .init(top: 12, left: 30, bottom: 0, right: 30))
            
            view.addSubview(backButton)
            backButton.anchor(top: label.topAnchor, leading: view.leadingAnchor, bottom: label.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 6, bottom: 0, right: 0))
            
            view.addSubview(ageTextField)
            ageTextField.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: view.bounds.height/5, left: 60, bottom: 0, right: 60))
            
            view.addSubview(underline)
            underline.anchor(top: ageTextField.bottomAnchor, leading: ageTextField.leadingAnchor, bottom: nil, trailing: ageTextField.trailingAnchor)
            
            view.addSubview(doneBttn)
            doneBttn.anchor(top: underline.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 20, left: 120, bottom: 0, right: 120))
            
            view.addSubview(errorLabel)
            errorLabel.isHidden = true
            errorLabel.anchor(top: doneBttn.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 40, left: 20, bottom: 0, right: 20))
        }
        
        let underline: UIView = {
            let view = UIView()
            view.heightAnchor.constraint(equalToConstant: 4).isActive = true
            view.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.6705882353, alpha: 1)
            return view
        }()
        
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
            label.text = "Edit Birthday"
            label.textColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
            label.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            
            return label
        }()
        
        private let errorLabel: UILabel = {
            let label = UILabel()
            
            label.text = "Enter Your Birthday"
            label.textColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
            label.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            return label
        }()
        
        
        private let doneBttn: UIButton = {
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

    }

