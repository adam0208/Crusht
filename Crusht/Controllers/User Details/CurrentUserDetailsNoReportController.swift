//
//  CurrentUserDetailsNoReportController.swift
//  Crusht
//
//  Created by William Kelly on 5/5/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase


class CurrentUserDetailsNoReportController: UIViewController, UIScrollViewDelegate {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    var cardViewModel: CardViewModel! {
        didSet {
            infoLabel.attributedText = cardViewModel.attributedString
            
            swipingPhotosController.cardViewModel = cardViewModel
        }
    }
    
    //lazy var to access self
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        sv.delegate = self
        return sv
    }()
    
    fileprivate var crushScore: CrushScore?
    
    fileprivate func setLabelText() {
        
        let uid = cardViewModel.uid
        Firestore.firestore().collection("score").document(uid).getDocument { (snapshot, err) in
            if err != nil {
                return
            }
            
            if snapshot?.exists == true {
                guard let dictionary = snapshot?.data() else { return }
                let crushScore = CrushScore(dictionary: dictionary)
                self.crushScore = CrushScore(dictionary: dictionary)
                self.crushScoreLabel.text = crushScore.toString
            }
            else {
                self.crushScoreLabel.text = " Crusht Score: 😊"
            }
        }
        
    }
    
    
    let swipingPhotosController = SwipingPhotosController(isCardViewMode: false)
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 0
        return label
    }()
    
    let crushScoreLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.numberOfLines = 0
        return label
    }()
    
    let bioLabel: UILabel = {
        let label = UILabel()
        label.text = "No Bio Available"
        label.numberOfLines = 0
        return label
    }()
    
    
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(#imageLiteral(resourceName: "icons8-back-filled-30").withRenderingMode(.alwaysOriginal), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        
        return button
    }()
    
    
    
    //    lazy var dislikeButton = self.createButton(image: #imageLiteral(resourceName: "dismiss_circle"), selector: #selector(handleDislike))
    //    lazy var superLikeButton = self.createButton(image: #imageLiteral(resourceName: "super_like_circle"), selector: #selector(handleDislike))
    //    lazy var likeButton = self.createButton(image: #imageLiteral(resourceName: "like_circle"), selector: #selector(handleDislike))
    
    @objc fileprivate func handleDislike() {
    }
    
    //    let likeBttn: UIButton = {
    //        let button = UIButton(type: .system)
    //        button.titleLabel?.font = UIFont.systemFont(ofSize: 60)
    //        button.setTitle("👍", for: .normal)
    //        button.backgroundColor = .white
    //        button.heightAnchor.constraint(equalToConstant: 50)
    //        button.widthAnchor.constraint(equalToConstant: 50)
    //        button.layer.cornerRadius = 50
    //        return button
    //    }()
    //
    //    let disLikeBttn: UIButton = {
    //        let button = UIButton(type: .system)
    //        button.titleLabel?.font = UIFont.systemFont(ofSize: 60)
    //        button.setTitle("👎", for: .normal)
    //        button.backgroundColor = .white
    //        button.heightAnchor.constraint(equalToConstant: 50)
    //        button.widthAnchor.constraint(equalToConstant: 50)
    //        button.layer.cornerRadius = 50
    //
    //        //button.layer.masksToBounds = true
    //        return button
    //    }()
    
    //    fileprivate func createButton(image: UIImage, selector: Selector) -> UIButton {
    //        let button = UIButton(type: .system)
    //        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
    //        button.addTarget(self, action: selector, for: .touchUpInside)
    //        button.imageView?.contentMode = .scaleAspectFill
    //        return button
    //    }
    
    @objc fileprivate func handleDismiss() {
        navigationController?.isNavigationBarHidden = false
        navigationController?.popToRootViewController(animated: true)
    }

    
    //    fileprivate func setupBottomControls() {
    //        let stackView = UIStackView(arrangedSubviews: [disLikeBttn, UIView(), likeBttn])
    //        stackView.distribution = .fillEqually
    //        stackView.spacing = -32
    //        view.addSubview(stackView)
    //        stackView.anchor(top: nil, leading: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 300, height: 80))
    //        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    //    }
    
    fileprivate func setupLayout() {
        view.backgroundColor = .white
        self.setLabelText()
        let swipingView = swipingPhotosController.view!
        scrollView.addSubview(swipingView)
        swipingView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width)
        
        scrollView.addSubview(infoLabel)
        infoLabel.anchor(top: swipingView.bottomAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: scrollView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(crushScoreLabel)
        bioLabel.text = cardViewModel.bio
        crushScoreLabel.anchor(top: infoLabel.bottomAnchor, leading: infoLabel.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 8, left: 0, bottom: 16, right: 16))
        scrollView.addSubview(bioLabel)
        
        bioLabel.anchor(top: crushScoreLabel.bottomAnchor, leading: crushScoreLabel.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 8, left: 0, bottom: 16, right: 16))
        
        scrollView.fillSuperview()
    }
    
    fileprivate let extraSwipingHeight: CGFloat = 100
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let swipingView = swipingPhotosController.view!
        swipingView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width + extraSwipingHeight)
    }
    
    fileprivate func setupVisualBlurEffectView() {
        let blurEffect = UIBlurEffect(style: .regular)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        
        view.addSubview(visualEffectView)
        visualEffectView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-information-30"), style: .plain, target: self, action: #selector(handleInfo))
       
        setupLayout()
        setupVisualBlurEffectView()
    }
    

    
    @objc fileprivate func handleInfo() {
        let infoView = InfoView()
        infoView.infoText.text = "Crush Score: Your Crush Score increases when you like or get liked by someone."
        navigationController?.view.addSubview(infoView)
        infoView.fillSuperview()
        //hud.textLabel.text = "Crush Score: Your Crush Score increases when you like or get liked by someone."
        //hud.show(in: navigationController!.view)
        //hud.dismiss(afterDelay: 3)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let  changeY = -scrollView.contentOffset.y
        var width = view.frame.width + changeY * 2
        width = max(view.frame.width, width)
        //changeY is NEGATIVE
        let imageView = swipingPhotosController.view!
        
        imageView.frame = CGRect(x: min(0,-changeY), y: min(0, -changeY), width: width, height: width)
    }
    

    //@objc fileprivate func handleTapDismiss () {
    //    self.dismiss(animated: true)
    //}
}
