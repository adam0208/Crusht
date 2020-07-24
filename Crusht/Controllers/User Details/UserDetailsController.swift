//
//  UserDetailsController.swift
//  Crusht
//
//  Created by William Kelly on 12/9/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

//Fix this

class UserDetailsController: UIViewController, UIScrollViewDelegate {
    let swipingPhotosController = SwipingPhotosController(isCardViewMode: false)
    let extraSwipingHeight: CGFloat = 100
    
    
    var cardViewModel: CardViewModel! {
        didSet {
            infoLabel.attributedText = cardViewModel.attributedString
            swipingPhotosController.cardViewModel = cardViewModel
        }
    }
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let swipingView = swipingPhotosController.view!
        swipingView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width + extraSwipingHeight)
    }
    
    let schoolController = SchoolCrushController()
    
    // MARK: - Logic
    
    @objc private func handleDismiss() {
        navigationController?.isNavigationBarHidden = false
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func handleReport() {
        let reportController = ReportControllerViewController()
        reportController.reportUID = cardViewModel.uid
        reportController.uid = Auth.auth().currentUser!.uid
        reportController.reportName = cardViewModel.attributedString.string
        reportController.reportPhoneNumebr = cardViewModel.phone
        
        let myBackButton = UIBarButtonItem()
        myBackButton.title = " "
        navigationItem.backBarButtonItem = myBackButton
        navigationController?.pushViewController(reportController, animated: true)
    }
    
    @objc private func handleBlock() {
        
        let alert = UIAlertController(title: "Block User", message: "Block this user? This action is permanent", preferredStyle: .alert)
        let action = UIAlertAction(title: "Block", style: .default){(UIAlertAction) in
        guard let uid = Auth.auth().currentUser?.uid else {return}
                 
        let documentData = [self.cardViewModel.uid: 1]
        
                 Firestore.firestore().collection("blocks").document(uid).setData(documentData, merge: true) { (err) in
                 if err != nil {
                     return
                     }
                     self.handleDismiss()
                 }
        }
        let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        return
        
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let changeY = -scrollView.contentOffset.y
        var width = view.frame.width + changeY * 2
        width = max(view.frame.width, width)
        let imageView = swipingPhotosController.view!
        
        // changeY is NEGATIVE
        imageView.frame = CGRect(x: min(0,-changeY), y: min(0, -changeY), width: width, height: width)
    }
    
    // MARK: - User Interface
    
    private func initializeUI() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-exclamation-mark-32").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleReport)), UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-hide-30-2").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleBlock))]
        
        view.backgroundColor = .white
        
        let swipingView = swipingPhotosController.view!
        scrollView.addSubview(swipingView)
        swipingView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width)
       
        scrollView.addSubview(infoLabel)
        infoLabel.anchor(top: swipingView.bottomAnchor,
                         leading: scrollView.leadingAnchor,
                         bottom: nil,
                         trailing: scrollView.trailingAnchor,
                         padding: .init(top: 16, left: 16, bottom: 0, right: 16))

        view.addSubview(scrollView)
        bioLabel.text = cardViewModel.bio
      
        
        scrollView.addSubview(bioLabel)
        bioLabel.anchor(top: infoLabel.bottomAnchor,
                        leading: infoLabel.leadingAnchor,
                        bottom: nil,
                        trailing: view.trailingAnchor,
                        padding: .init(top: 8, left: 0, bottom: 16, right: 16))
        
        scrollView.fillSuperview()
        setupVisualBlurEffectView()
    }
    
    private func setupVisualBlurEffectView() {
        let blurEffect = UIBlurEffect(style: .regular)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(visualEffectView)
        visualEffectView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    // Lazy var to access self
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        sv.delegate = self
        return sv
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 0
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.text = "No Bio Available"
        label.numberOfLines = 0
        return label
    }()
    
    
    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(#imageLiteral(resourceName: "icons8-back-filled-30").withRenderingMode(.alwaysOriginal), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
            
        return button
    }()
}
