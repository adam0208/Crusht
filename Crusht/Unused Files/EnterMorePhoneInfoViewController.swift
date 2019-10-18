////
////  EnterMorePhoneInfoViewController.swift
////  Crusht
////
////  Created by William Kelly on 1/21/19.
////  Copyright © 2019 William Kelly. All rights reserved.
////
//
//import UIKit
//import Firebase
//import JGProgressHUD
//import SDWebImage
//
//extension EnterMorePhoneInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        let image = info[.originalImage] as? UIImage
//        registrationViewModel.checkFormValidity()
//        registrationViewModel.bindableImage.value = image
//        dismiss(animated: true, completion: nil)
//    }
//}
//
//class EnterMorePhoneInfoViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
//  
//    
// 
//    // MARK: UIPickerView Delegation
//    
//    @objc func donedatePicker(){
//        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd/MM/yyyy"
//        ageTextField.text = formatter.string(from: datepicker.date)
//        
//        self.view.endEditing(true)
//    }
//    
//    @objc func cancelDatePicker(){
//        self.view.endEditing(true)
//        registrationViewModel.birthday = "\(ageTextField.text ?? "10-31-1995") "
//        registrationViewModel.age = self.calcAge(birthday: ageTextField.text!)
//    }
//
//    
//    @objc func dateChanged() {
//        let components = Calendar.current.dateComponents([.year, .month, .day], from: datepicker.date)
//        if let day = components.day, let month = components.month, let year = components.year {
//            print("\(day) \(month) \(year)")
//           ageTextField.text = "\(day)-\(month)-\(year)"
//        registrationViewModel.birthday = "\(ageTextField.text ?? "10-31-1995") "
//            registrationViewModel.age = self.calcAge(birthday: ageTextField.text!)
//        }
//        
//    }
//    
//    func calcAge(birthday: String) -> Int {
//        let dateFormater = DateFormatter()
//        dateFormater.dateFormat = "MM/dd/yyyy"
//        let birthdayDate = dateFormater.date(from: birthday)
//        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
//        let now = Date()
//        let calcAge = (calendar.components(.year, from: birthdayDate ?? dateFormater.date(from: "10-31-1995")!, to: now, options: []))
//        let age = calcAge.year
//        return age!
//    }
//    
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return myPickerData.count
//    }
//    
//    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return myPickerData[row]
//    }
//    
//    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        schoolTextField.text = myPickerData[row]
//        registrationViewModel.school = schoolTextField.text
//        
//    }
//    
//    let myPickerData = Constants.universityList
//    
//    var delegate: LoginControllerDelegate?
//    
//    let selectPhotoButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Select Photo", for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
//        button.backgroundColor = .white
//        button.setTitleColor(.black, for: .normal)
//        button.layer.cornerRadius = 16
//        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
//        button.imageView?.contentMode = .scaleAspectFill
//        button.clipsToBounds = true
//        return button
//    }()
//    
//    @objc func handleSelectPhoto() {
//        let imagePickerController = UIImagePickerController()
//        imagePickerController.delegate = self
//        present(imagePickerController, animated: true)
//    }
//    
//    var schoolPicker = UIPickerView()
//    
//    lazy var selectPhotoButtonWidthAnchor = selectPhotoButton.widthAnchor.constraint(equalToConstant: 275)
//    lazy var selectPhotoButtonHeightAnchor = selectPhotoButton.heightAnchor.constraint(equalToConstant: 275)
//    
//    let fullNameTextField: CustomTextField = {
//        let tf = CustomTextField(padding: 10, height: 45)
//        tf.placeholder = "Enter full name"
//        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
//        return tf
//    }()
//    
//    let schoolTextField: CustomTextField = {
//        let tf = CustomTextField(padding: 10, height: 45)
//        tf.placeholder = "Enter School"
//       
//        
//        return tf
//    }()
//    
//    let emailTextField: CustomTextField = {
//        let tf = CustomTextField(padding: 10, height: 45)
//        tf.placeholder = "Enter email"
//        tf.keyboardType = .emailAddress
//        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
//        return tf
//    }()
//    
//    let ageTextField: CustomTextField = {
//        let tf = CustomTextField(padding: 10, height: 45)
//        tf.placeholder = "Enter Birthday"
//        return tf
//    }()
//    
//    let bioTextField: CustomTextField = {
//        let tf = CustomTextField(padding: 10, height: 45)
//        tf.placeholder = "Bio"
//        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
//        return tf
//    }()
//    
//    
//    @objc fileprivate func handleTextChange(textField: UITextField) {
//        if textField == fullNameTextField {
//            registrationViewModel.fullName = textField.text
//        } else if textField == emailTextField {
//            registrationViewModel.email = textField.text
//        }
//        else {
//            registrationViewModel.bio = textField.text
//        
//        }
//    }
//    
//    let registerButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Log in", for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
//        //        button.backgroundColor = #colorLiteral(red: 0.8235294118, green: 0, blue: 0.3254901961, alpha: 1)
//        button.backgroundColor = .lightGray
//        button.setTitleColor(.gray, for: .disabled)
//        button.isEnabled = false
//        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
//        button.layer.cornerRadius = 22
//        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
//        return button
//    }()
//    
//    let registeringHUD = JGProgressHUD(style: .dark)
//    let profilePageViewController = ProfilePageViewController()
//    
//    
//    var user: User?
//    
//    fileprivate func fetchCurrentUser() {
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
//            if let err = err {
//                print(err)
//                return
//            }
//            
//            guard let dictionary = snapshot?.data() else {return}
//            self.user = User(dictionary: dictionary)
//
//            self.registrationViewModel.phone = self.user?.phoneNumber ?? "123"
//            self.fullNameTextField.text = self.user?.name ?? ""
//            //self.emailTextField.text = self.user?.email ?? ""
//            self.registrationViewModel.fbid = self.user?.fbid ?? ""
//            
//            //self.registrationViewModel.fullName?.isEmpty == false
//            
//            self.loadUserPhotos()
//            
//        }
//    }
//    
//    fileprivate func loadUserPhotos() {
//        guard let imageUrl = user?.imageUrl1, let url = URL(string: imageUrl) else {return}
//        SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
//            self.selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
//        }
//        //registrationViewModel.bindableImage.value != nil
//        //self.user?.imageUrl1
//    }
//    
//    @objc fileprivate func handleRegister() {
//        self.handleTapDismiss()
//        print("Register our User in Firebase Auth")
//        let genderController = GenderController()
//        registrationViewModel.age = self.calcAge(birthday: ageTextField.text!)
//        registrationViewModel.performRegistration { [weak self] (err) in
//            if let err = err {
//                self?.showHUDWithError(error: err)
//                return
//            }
//            self?.present(genderController, animated: true)
//        }
//        
//    }
//    
//      let registrationViewModel = RegistrationViewModel()
//    
//    fileprivate func setupRegistrationViewModelObserver() {
//        registrationViewModel.bindableIsFormValid.bind { [unowned self] (isFormValid) in
//            guard let isFormValid = isFormValid else { return }
//            self.registerButton.isEnabled = isFormValid
//            self.registerButton.backgroundColor = isFormValid ? #colorLiteral(red: 1, green: 0.6745098039, blue: 0.7215686275, alpha: 1) : .lightGray
//            self.registerButton.setTitleColor(isFormValid ? .white : .gray, for: .normal)
//        }
//        registrationViewModel.bindableImage.bind { [unowned self] (img) in self.selectPhotoButton.setImage(img?.withRenderingMode(.alwaysOriginal), for: .normal)
//        }
//        registrationViewModel.bindableIsRegistering.bind { [unowned self] (isRegistering) in
//            if isRegistering == true {
//                self.registeringHUD.textLabel.text = "Registering"
//                self.registeringHUD.show(in: self.view)
//            } else {
//                self.registeringHUD.dismiss()
//            }
//        }
//    }
//        
//        fileprivate func showHUDWithError(error: Error) {
//            registeringHUD.dismiss()
//            let hud = JGProgressHUD(style: .dark)
//            hud.textLabel.text = "Failed registration"
//            hud.detailTextLabel.text = error.localizedDescription
//            hud.show(in: self.view)
//            hud.dismiss(afterDelay: 3)
//        }
//    
//    var datepicker = UIDatePicker()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//       datepicker.datePickerMode = .date
//        datepicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
//        schoolPicker.delegate = self
//        schoolTextField.inputView = schoolPicker
//       // datepicker.delegate = self
//        ageTextField.inputView = datepicker
//        let toolbar = UIToolbar();
//        toolbar.sizeToFit()
//      
//     
//        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
//           let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
//          let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
//        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
//        
//        ageTextField.inputAccessoryView = toolbar
//        
//        fetchCurrentUser()
//        setupGradientLayer()
//        setupLayout()
//        setupNotificationObservers()
//        setupTapGesture()
//        setupRegistrationViewModelObserver()
//        
//    }
//    
//    lazy var verticalStackView: UIStackView = {
//        let sv = UIStackView(arrangedSubviews: [
//            fullNameTextField,
//            schoolTextField,
//            ageTextField,
//            emailTextField,
//            bioTextField,
//            registerButton
//            ])
//        sv.axis = .vertical
//        sv.spacing = 10
//        return sv
//    }()
//    
//    lazy var overallStackView = UIStackView(arrangedSubviews: [
//        selectPhotoButton,
//        verticalStackView
//        ])
//    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        if self.traitCollection.verticalSizeClass == .compact {
//            overallStackView.axis = .horizontal
//            verticalStackView.distribution = .fillEqually
//            selectPhotoButtonHeightAnchor.isActive = false
//            selectPhotoButtonWidthAnchor.isActive = true
//        } else {
//            overallStackView.axis = .vertical
//            verticalStackView.distribution = .fill
//            selectPhotoButtonWidthAnchor.isActive = false
//            selectPhotoButtonHeightAnchor.isActive = true
//        }
//    }
//    
//    fileprivate func setupLayout() {
//        view.addSubview(overallStackView)
//        
//        overallStackView.axis = .vertical
//        overallStackView.spacing = 16
//        overallStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 20, left: 50, bottom: 20, right: 50))
//        overallStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        
//        
//    }
//    
//    fileprivate func setupTapGesture() {
//        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
//        
//    }
//    
//    @objc fileprivate func handleTapDismiss() {
//        donedatePicker() //make sure date is saved
//        self.view.endEditing(true) // dismisses keyboard
//        
//    }
//    
//    fileprivate func setupNotificationObservers() {
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        //NotificationCenter.default.removeObserver(self) // Comment out to proper keyboard
//        
//    }
//    
//    @objc fileprivate func handleKeyboardHide() {
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
//            self.view.transform = .identity
//        })
//    }
//    
//    @objc fileprivate func handleKeyboardShow(notification: Notification) {
//        // how to figure out how tall the keyboard actually is
//        guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
//        let keyboardFrame = value.cgRectValue
//        print(keyboardFrame)
//        
//        // let's try to figure out how tall the gap is from the register button to the bottom of the screen
//        let bottomSpace = view.frame.height - overallStackView.frame.origin.y - overallStackView.frame.height
//        print(bottomSpace)
//        
//        let difference = keyboardFrame.height - bottomSpace
//        self.view.transform = CGAffineTransform(translationX: 0, y: -difference - 8)
//    }
//    
//    //picker for schools
//    
//
//    
//    
//    
//    let gradientLayer = CAGradientLayer()
//    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        gradientLayer.frame = view.bounds
//        
//    }
//    
//    fileprivate func setupGradientLayer() {
//        
//        let topColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
//        let bottomColor = #colorLiteral(red: 0.8755432963, green: 0.4065410793, blue: 0, alpha: 1)
//        // make sure to user cgColor
//        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
//        gradientLayer.locations = [0, 1]
//        view.layer.addSublayer(gradientLayer)
//        gradientLayer.frame = view.bounds
//    }
//
//}
