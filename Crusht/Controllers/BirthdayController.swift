//
//  BirthdayController.swift
//  Crusht
//
//  Created by William Kelly on 4/14/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import JGProgressHUD

class BirthdayController: UIViewController {
    
    
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        ageTextField.text = formatter.string(from: datepicker.date)
        
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
      
    }
    
    
    @objc func dateChanged() {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: datepicker.date)
        if let day = components.day, let month = components.month, let year = components.year {
            ageTextField.text = "\(month)-\(day)-\(year)"
            
        }
        
    }
    
    
    
    func calcAge(birthday: String) -> Int {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM/dd/yyyy"
        let birthdayDate = dateFormater.date(from: birthday)
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
        let now = Date()
        let calcAge = (calendar.components(.year, from: birthdayDate ?? dateFormater.date(from: "10-31-1995")!, to: now, options: []))
        let age = calcAge.year
        return age!
    }
    

    let ageTextField: UITextField = {
        let tf = NameTextField()
        tf.placeholder = "Birthday"
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 15
        tf.font = UIFont.systemFont(ofSize: 25)
        tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
        return tf
    }()
    
    let label: UILabel = {
        let label = UILabel()
        
        label.text = "Enter your Birthday"
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.textAlignment = .center
         label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    
    let doneBttn: UIButton = {
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
        let bday = ageTextField.text?.replacingOccurrences(of: "/", with: "-")
        
        birthday = bday ?? "10-30-1999"
        age = calcAge(birthday: birthday)
        if ageTextField.text == "" {
            hud.textLabel.text = "Please enter your b-day"
            hud.show(in: view)
            hud.dismiss(afterDelay: 2)
            return
        }
        else if age < 18 {
            hud.textLabel.text = "Must be 18 or older to join"
            hud.show(in: view)
            hud.dismiss(afterDelay: 2)
            return
        }
        else {
          
           
            let enterSchoolController = EnterSchoolController()
            enterSchoolController.name = name
            enterSchoolController.birthday = birthday
            enterSchoolController.age = age
            enterSchoolController.phone = phone
            present(enterSchoolController, animated: true)
        }
        
    }
    
    var user: User?
    var phone: String!
    var name = String()
      var birthday = String()
    var age = Int()
    
    var datepicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datepicker.datePickerMode = .date
        ageTextField.inputView = datepicker
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        ageTextField.inputAccessoryView = toolbar
        
        setupGradientLayer()
        
        let stack = UIStackView(arrangedSubviews: [ageTextField, doneBttn])
        view.addSubview(stack)
        
        stack.axis = .vertical
        
        view.addSubview(label)
        
        label.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: view.bounds.height/5, left: 30, bottom: 0, right: 30))
        
        stack.anchor(top: label.bottomAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 4, left: 30, bottom: view.bounds.height/2.2, right: 30))
        
        stack.spacing = 20
        
        
    }
    
    @objc fileprivate func handleTapDismiss() {
        donedatePicker() //make sure date is saved
        self.view.endEditing(true) // dismisses keyboard
        
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
    


}
