//
//  SettingsTableViewController.swift
//  Crusht
//
//  Created by William Kelly on 12/8/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
import SDWebImage
import FacebookCore
import FacebookLogin

protocol SettingsControllerDelegate {
    func didSaveSettings()
}

class CustomImagePickerController: UIImagePickerController  {
    var imageBttn: UIButton?
}

class SettingsTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    var delegate: SettingsControllerDelegate?
    
    lazy var image1Button = createBttn(selector: #selector(handleSelectPhoto))
    lazy var image2Button = createBttn(selector: #selector(handleSelectPhoto))
    lazy var image3Button = createBttn(selector: #selector(handleSelectPhoto))

    @objc func handleSelectPhoto(button: UIButton) {
        let imagePicker = CustomImagePickerController()
        imagePicker.delegate = self
        imagePicker.imageBttn = button
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        
        let imageButton = (picker as? CustomImagePickerController)?.imageBttn
        
        imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        dismiss(animated: true)
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Uploading image..."
        hud.show(in: view)
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        guard let uploadData = selectedImage?.jpegData(compressionQuality: 0.75) else {return}
        ref.putData(uploadData, metadata: nil) { (nil, err) in
            hud.dismiss()
            if let err = err {
                print("Failed to upload photo", err)
                hud.dismiss()
                return
            }
            ref.downloadURL(completion: { (url, err) in
                hud.dismiss()
                if let err = err {
                    print("Failed to download url", err)
                    return
                }
                
                if imageButton == self.image1Button {
                    self.user?.imageUrl1 = url?.absoluteString
                } else if imageButton == self.image2Button {
                    self.user?.imageUrl2 = url?.absoluteString
                }
                else {
                    self.user?.imageUrl3 = url?.absoluteString
                }
            })
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myPickerData.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return myPickerData[row]
    }
    
   
    var genderPicker = UIPickerView()
    
    let myPickerData = [String](arrayLiteral: " ", "He/Him/His", "She/Her/Hers", "All Humans")
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        fetchCurrentUser()
        self.tableView.reloadData()
    }
    
    
    func createBttn(selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.backgroundColor = .white
        
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientLayer()
        setUpNavItems()
        //view.backgroundColor = .blue
        //tableView.backgroundColor = UIColor.clear
        //tableView.tableFooterView?.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        tableView.keyboardDismissMode = .onDrag
        let bioCell = BioCell()
        bioCell.textView.delegate = self
        //view.bringSubviewToFront(tableView)
        //tableView.fillSuperview()
        //setupGradientLayer()
        fetchCurrentUser()
        
        
    }
    
   // let hud = JGProgressHUD(style: .light)
    
    var user: User?
    
    fileprivate func fetchCurrentUser() {
            
            guard let uid = Auth.auth().currentUser?.uid else {return}
            Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
                if let err = err {
                    print(err)
                    return
                }
                //print(snapshot?.data())
                guard let dictionary = snapshot?.data() else {return}
                self.user = User(dictionary: dictionary)
            }
            
            self.loadUserPhotos()
            
            self.tableView.reloadData()
            
        }
        
    
    
    fileprivate func loadUserPhotos() {
        
        //maybe refactor this
        
        if let imageUrl = user?.imageUrl1, let url = URL(string: imageUrl) {
        SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
            self.image1Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        //self.user?.imageUrl1
    }
        if let imageUrl = user?.imageUrl2, let url = URL(string: imageUrl) {
            SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image2Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
            if let imageUrl = user?.imageUrl3, let url = URL(string: imageUrl) {
                SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                    self.image3Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
                }
        }
         self.tableView.reloadData()
    }
    
    
    lazy var header: UIView = {
        let header = UIView()
        header.addSubview(image1Button)
        let padding: CGFloat = 16
        image1Button.anchor(top: header.topAnchor, leading: header.leadingAnchor, bottom: header.bottomAnchor, trailing: nil, padding: .init(top: padding, left: padding, bottom: padding, right: 0))
        image1Button.widthAnchor.constraint(equalTo: header.widthAnchor, multiplier: 0.45).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [image2Button, image3Button])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = padding
        
        header.addSubview(stackView)
        stackView.anchor(top: header.topAnchor, leading: image1Button.trailingAnchor, bottom: header.bottomAnchor, trailing: header.trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        return header
    }()
    
    class SettingsHeaderLabel: UILabel {
        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.insetBy(dx: 16, dy: 0))
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return header
        }
        let headerLabel = SettingsHeaderLabel()
        headerLabel.font = UIFont.boldSystemFont(ofSize: 18)
        switch section {
        case 1:
            headerLabel.text = ""
        case 2 :
            headerLabel.text = ""
        case 3:
            headerLabel.text = ""
        case 4:
             headerLabel.text = ""
        case 5:
            headerLabel.text = ""
        case 6:
            headerLabel.text = ""
        case 7:
            headerLabel.text = "Match by Locantion prefrences"
    
        default:
            headerLabel.text = ""
        }
        

        return headerLabel
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 300
        }
      
            
        else if section == 7 {
            return 45
        }
            
        else if section == 9 || section == 10 {
            return 20
        }
        else {
        return 15
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 11
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SettingsCells(style: .default, reuseIdentifier: nil)
        

        
        if indexPath.section == 7 {
            let ageRangeCell = AgeRangeTableViewCell(style: .default, reuseIdentifier: nil)
            ageRangeCell.minSlider.addTarget(self, action: #selector(handleMinChanged), for: .valueChanged)
            ageRangeCell.maxSlider.addTarget(self, action: #selector(handleMaxChanged), for: .valueChanged)
            
            ageRangeCell.minLabel.text = " Min Age: \(user?.minSeekingAge ?? 18)"
            ageRangeCell.maxLabel.text = " Max Age: \(user?.maxSeekingAge ?? 50)"
            
            ageRangeCell.minSlider.value = Float(user?.minSeekingAge ?? 18)
            ageRangeCell.maxSlider.value = Float(user?.maxSeekingAge ?? 50)
            ageRangeCell.layer.cornerRadius = 22
            ageRangeCell.layer.masksToBounds = true
            return ageRangeCell
        }
        else if indexPath.section == 8 {
            let locationRangeCell = LocationTableViewCell(style: .default, reuseIdentifier: nil)
        //    locationRangeCell.minSlider.addTarget(self, action: #selector(handleMinChangedDistance), for: .valueChanged)
            locationRangeCell.maxSlider.addTarget(self, action: #selector(handleMaxChangedDistance), for: .valueChanged)
            
         //   locationRangeCell.minLabel.text = " Min Km: \(user?.minDistance ?? 1)"
            locationRangeCell.maxLabel.text = " Miles: \(user?.maxDistance ?? 50)"
            
            //locationRangeCell.minSlider.value = Float(user?.minDistance ?? 1)
            locationRangeCell.maxSlider.value = Float(user?.maxDistance ?? 50)
            
            locationRangeCell.layer.cornerRadius = 16
            locationRangeCell.layer.masksToBounds = true
    
            return locationRangeCell
        }
        else if indexPath.section == 9 {
            
            let fbCell = FbConnectCell(style: .default, reuseIdentifier: nil)
            fbCell.FBLoginBttn.addTarget(self, action: #selector(loginFB), for: .touchUpInside)
            return fbCell
           
        }
        
        else if indexPath.section == 10 {
            let logoutCell = LogoutBttnCell(style: .default, reuseIdentifier: nil)
            
            logoutCell.logOutBttn.addTarget(self, action: #selector(handleLogOut), for: .touchUpInside)
            
            return logoutCell
        }
    
        
        switch indexPath.section {
        case 1:
            cell.textField.placeholder = "Name"
            cell.textField.text = user?.name
            cell.textField.addTarget(self, action: #selector(handleNameChange), for: .editingChanged)
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true
        case 2 :
            cell.textField.placeholder = "School"
            cell.textField.text = user?.school
            cell.textField.addTarget(self, action: #selector(handleSchoolChange), for: .editingChanged)
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true
        case 3:
            cell.textField.placeholder = "Age"
            let age = calcAge(birthday: (user?.birthday ?? "10-31-1995"))
            cell.textField.text = String(age)
                 cell.isUserInteractionEnabled = false
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true
            
            
            //cell.textField.addTarget(self, action: #selector(handleAgeChange), for: .editingChanged)
        case 4:
            let bioCell = BioCell(style: .default, reuseIdentifier: nil)
            bioCell.textView.font = UIFont.systemFont(ofSize: 16)
            bioCell.textView.text = user?.bio
            bioCell.textView.delegate = self
             
            textViewDidChange(bioCell.textView)
            
            bioCell.layer.cornerRadius = 22
            bioCell.layer.masksToBounds = true
            return bioCell
//            cell.textField.placeholder = "Bio"
//            cell.textField.text = user?.bio
//
//            cell.textField.addTarget(self, action: #selector(handleBioChange), for: .editingChanged)
         
        case 5:
            cell.textField.placeholder = "Sex"
                cell.isUserInteractionEnabled = false
            cell.textField.text = user?.gender
            cell.textField.addTarget(self, action: #selector(handleGenderChange), for: .editingChanged)
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true
            
        default:
            cell.textField.placeholder = "Sex Preference"
            cell.isUserInteractionEnabled = false
            cell.textField.text = user?.sexPref
            cell.textField.addTarget(self, action: #selector(handleSexPrefChange), for: .editingChanged)
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true
            
        }
        
        return cell
    }
    
    public func textViewDidChange(_ textView: UITextView){
       user?.bio = textView.text
        
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return range.location < 200
    }
    
    @objc fileprivate func handleMinChanged (slider: UISlider) {
       
      evaluateMinMax()
    }
    
    @objc fileprivate func handleMaxChanged (slider: UISlider) {
       
      evaluateMinMax()
    }
    
    @objc fileprivate func handleMinChangedDistance (slider: UISlider) {
        
        evaluateMinMaxDistance()
    }
    
    @objc fileprivate func handleMaxChangedDistance (slider: UISlider) {
        
        evaluateMinMaxDistance()
    }
    
    
    fileprivate func evaluateMinMax() {
        guard let ageRangeCell = tableView.cellForRow(at: [7, 0]) as? AgeRangeTableViewCell else { return }
        let minValue = Int(ageRangeCell.minSlider.value)
        var maxValue = Int(ageRangeCell.maxSlider.value)
        maxValue = max(minValue, maxValue)
        ageRangeCell.maxSlider.value = Float(maxValue)
        ageRangeCell.minLabel.text = "Min Age \(minValue)"
        ageRangeCell.maxLabel.text = "Max Age \(maxValue)"
        
        user?.minSeekingAge = minValue
        user?.maxSeekingAge = maxValue
    }
    
    fileprivate func evaluateMinMaxDistance() {
        guard let locationRangeCell = tableView.cellForRow(at: [8, 0]) as? LocationTableViewCell else { return }
        //let minValue = Int(locationRangeCell.minSlider.value)
        var maxValue = Int(locationRangeCell.maxSlider.value)
        maxValue = max(maxValue, 1)
        locationRangeCell.maxSlider.value = Float(maxValue)
        //locationRangeCell.minLabel.text = "Min \(minValue)"
        locationRangeCell.maxLabel.text = " Miles \(maxValue)"
        
        user?.maxDistance = maxValue
    }
    
    @objc fileprivate func handleNameChange(textField: UITextField) {
        print("name changing")
        self.user?.name = textField.text
    }
    
    @objc fileprivate func handleSchoolChange(textField: UITextField) {
        self.user?.school = textField.text
    }
    
    @objc fileprivate func handleBioChange(textView: UITextView) {
        self.user?.bio = textView.text
       
        
    }
    
    @objc fileprivate func handleSexPrefChange(textField: UITextField) {
        self.user?.sexPref = textField.text
    }
    
    @objc fileprivate func handleGenderChange(textField: UITextField) {
        self.user?.gender = textField.text
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == 4 {
//            return 60
//        }
//        else { return 50 }
//    }
    
    fileprivate func setUpNavItems() {
        navigationItem.title = "Edit Profile"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleBack))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave))
        
    }
    let bioTextView = BioTextView()
    
    @objc fileprivate func handleSave() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return}
        let docData: [String: Any] = [
            "uid": uid,
            "Full Name": user?.name ?? "",
            "ImageUrl1": user?.imageUrl1 ?? "",
            "ImageUrl2": user?.imageUrl2 ?? "",
            "ImageUrl3": user?.imageUrl3 ?? "",
            "Age": calcAge(birthday: user?.birthday ?? "10-31-1995"),
            "Birthday": user?.birthday ?? "",
            "School": user?.school ?? "",
            "Bio": user?.bio ?? "",
            "minSeekingAge": user?.minSeekingAge ?? 18,
            "maxSeekingAge": user?.maxSeekingAge ?? 50,
            "maxDistance": user?.maxDistance ?? 3,
            "email": user?.email ?? "",
            "fbid": user?.fbid ?? "",
            "PhoneNumber": user?.phoneNumber ?? "",
            "deviceID": Messaging.messaging().fcmToken ?? "",
            "Gender-Preference": user?.sexPref ?? "",
            "User-Gender": user?.gender ?? "",
            "CurrentVenue": user?.currentVenue ?? ""
            ]
        
  //      let hud = JGProgressHUD(style: .dark)
//        hud.textLabel.text = "Saving Changes"
//        hud.show(in: view)
        Firestore.firestore().collection("users").document(uid).setData(docData) { (err)
            in
            //hud.dismiss()
            if let err = err {
                print("Failed to retrieve user settings", err)
                return
            }
            for viewController in self.tabBarController?.viewControllers ?? [] {
                if let navigationVC = viewController as? UINavigationController, let rootVC = navigationVC.viewControllers.first {
                    let _ = rootVC.view
                } else {
                    let _ = viewController.view
                }
            }
            
        
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
    
    @objc fileprivate func handleLogOut() {
        let firebaseAuth = Auth.auth()
        let loginViewController = LoginViewController()
        let navController = UINavigationController(rootViewController: loginViewController)
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
            }
            self.dismiss(animated: true)
            present(navController, animated: true)
        }
    
    @objc fileprivate func handleBack() {
        dismiss(animated: true)
    }

    let gradientLayer = CAGradientLayer()
    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        gradientLayer.frame = tableView.bounds
//
//    }
    
    fileprivate func setupGradientLayer() {
        
        let topColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        let bottomColor = #colorLiteral(red: 0.8755432963, green: 0.4065410793, blue: 0, alpha: 1)
        // make sure to user cgColor
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0, 1]
        tableView.layer.addSublayer(gradientLayer)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 1000)
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 800))
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
        self.tableView.backgroundView = backgroundView

    }
    
   @objc fileprivate func loginFB() {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self)  { (loginResult) in
            switch loginResult {
            case .failed(let error):
                print("cccccccccccccccccccccccccccccccccccccc",error)
            case .cancelled:
                print("User cancelled login.")
            case .success(grantedPermissions: _, declinedPermissions: _, token: _):
                print("Logged in!")
                self.fetchFBid()
            }
        }
    }
   
    fileprivate func fetchFBid() {
        let req = GraphRequest(graphPath: "me", parameters: ["fields": "email,first_name,last_name,gender,picture"], accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!)
        req.start({ (connection, result) in
            switch result {
            case .failed(let error):
                print(error)
            case .success(let graphResponse):
                if let responseDictionary = graphResponse.dictionaryValue {
                    print(responseDictionary)
                    
                    let socialIdFB = responseDictionary["id"] as? String
                    print(socialIdFB!)
                    
                    self.user?.fbid = socialIdFB!
                    
                }
            }
        })
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 9 || indexPath.section == 10 {
            cell.backgroundColor = UIColor.clear
        }
        else {
        cell.backgroundColor = UIColor.white
        }
    }
//    func setTableViewBackgroundGradient(sender: UITableViewController, _ topColor:UIColor, _ bottomColor:UIColor) {
//
//        let gradientBackgroundColors = [topColor.#colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1), bottomColor.#colorLiteral(red: 0.8755432963, green: 0.4065410793, blue: 0, alpha: 1)]
//        let gradientLocations = [0.0,1.0]
//
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = gradientBackgroundColors
//        gradientLayer.locations = gradientLocations
//
//        gradientLayer.frame = sender.tableView.bounds
//        let backgroundView = UIView(frame: sender.tableView.bounds)
//        backgroundView.layer.insertSublayer(gradientLayer, atIndex: 0)
//        sender.tableView.backgroundView = backgroundView
//    }
//
}


