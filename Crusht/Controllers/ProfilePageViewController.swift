//
//  ProfilePageViewController.swift
//  Crusht
//
//  Created by William Kelly on 12/5/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

extension ProfilePageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func  imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = info[.originalImage] as? UIImage
        profPicView.selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
}

class ProfilePageViewController: UIViewController, SettingsControllerDelegate, LoginControllerDelegate {
    
    func didFinishLoggingIn() {
        fetchCurrentUser()
    }
    
    let bottomStackView = ProfPageBottomStackView()
    let topStackView = ProfPageTopStackView()
    let profPicView = ProfPageMiddleView()
    //let profBttnView = ProfPageMidButtonView()
    
    @objc fileprivate func handleMatchByLocationBttnTapped() {
        let locationViewController = LocationMatchViewController()
        present(locationViewController, animated: true)
    }
    
    @objc fileprivate func handleFindCrushesTapped() {
        let transController = TransitionCrushesController()
        present(transController, animated: true)
    }
    
    @objc func handleSelectPhoto () {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    @objc func handleSettings() {
        let settingsController = SettingsTableViewController()
        settingsController.delegate = self
        let navController = UINavigationController(rootViewController: settingsController)
        present(navController, animated: true)
        
    }
    
    @objc func handleSeniorFive() {
        let seniorController = SeniorFiveTableViewController()
        let navController = UINavigationController(rootViewController: seniorController)
        present(navController, animated: true)
        
    }
    
    @objc func handleMessages() {
        let messageController = MessageController()
        let navController = UINavigationController(rootViewController: messageController)
        present(navController, animated: true)
        
    }
    
    
    func didSaveSettings() {
        print("Notified of dismissal")
        fetchCurrentUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("HomeController did appear")
        // you want to kick the user out when they log out
        if Auth.auth().currentUser == nil {
            let loginController = LoginViewController()
            loginController.delegate = self
            let navController = UINavigationController(rootViewController: loginController)
            present(navController, animated: true)
        }
    }
    
    fileprivate var crushScore: CrushScore?
    
    fileprivate func setLabelText() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        Firestore.firestore().collection("score").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            
            if snapshot?.exists == true {
                guard let dictionary = snapshot?.data() else {return}
                self.crushScore = CrushScore(dictionary: dictionary)
                if (self.crushScore?.crushScore ?? 0) > 10 {
                self.profPicView.greetingLabel.text = "You're on 🔥"
                }
            }
            else {
                self.profPicView.greetingLabel.text = "Hey Good Lookin' 😊"
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupGradientLayer()
        fetchCurrentUser()
        setLabelText()
        
        profPicView.layer.cornerRadius = 100

        profPicView.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        topStackView.homeButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        //view.backgroundColor = .white
        profPicView.matchByLocationBttm.addTarget(self, action: #selector(handleMatchByLocationBttnTapped), for: .touchUpInside)
        profPicView.findCrushesBttn.addTarget(self, action: #selector(handleFindCrushesTapped), for: .touchUpInside)
        //        topStackView.backgroundColor = #colorLiteral(red: 0.7607843137, green: 0.9294117647, blue: 0.6784313725, alpha: 1)
        //        bottomStackView.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        profPicView.selectPhotoButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        bottomStackView.seniorFive.addTarget(self, action: #selector(handleSeniorFive), for: .touchUpInside)
        topStackView.messageButton.addTarget(self, action: #selector(handleMessages), for: .touchUpInside)
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        setupLayout()
        
    }
    
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
            self.loadUserPhotos()
        }
    }
    
    let tippyTop: UIView = {
        let tT = UIView()
        tT.heightAnchor.constraint(equalToConstant: 20).isActive = true
        tT.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        return tT
    }()
    
    var user: User?
    
    fileprivate func loadUserPhotos() {
        guard let imageUrl = user?.imageUrl1, let url = URL(string: imageUrl) else {return}
        SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
            self.profPicView.selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        //self.user?.imageUrl1
    }
    
    fileprivate func setupLayout () {
        
        let overallStackView = UIStackView(arrangedSubviews: [tippyTop, topStackView, profPicView, bottomStackView])
        view.addSubview(overallStackView)
        
        overallStackView.axis = .vertical
        
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: -20, left: 0, bottom: 0, right: 0)
    }
    
    //    let gradientLayer = CAGradientLayer()
    //
    //    override func viewWillLayoutSubviews() {
    //        super.viewWillLayoutSubviews()
    //        gradientLayer.frame = view.bounds
    //    }
    //
    //    fileprivate func setupGradientLayer() {
    //        let topColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
    //        let bottomColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
    //        // make sure to user cgColor
    //        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
    //        gradientLayer.locations = [0, 1]
    //        view.layer.addSublayer(gradientLayer)
    //        gradientLayer.frame = view.bounds
    //    }
    
}
