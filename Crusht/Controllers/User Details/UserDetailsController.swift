//
//  UserDetailsController.swift
//  Crusht
//
//  Created by William Kelly on 12/9/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import Firebase

class UserDetailsController: UIViewController, UIScrollViewDelegate {
    
    //maybe create a viewmodel for user details?
    
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
            if let err = err {
                print(err)
                return
            }
            
            if snapshot?.exists == true {
                guard let dictionary = snapshot?.data() else {return}
                self.crushScore = CrushScore(dictionary: dictionary)
                
                if (self.crushScore?.crushScore ?? 0) > 10 && (self.crushScore?.crushScore ?? 0) <= 50 {
                    self.crushScoreLabel.text = "😊😎"
                }
                else if (self.crushScore?.crushScore ?? 0) > 50 && (self.crushScore?.crushScore ?? 0) <= 100 {
                    self.crushScoreLabel.text = "😊😎😍"
                }
                else if (self.crushScore?.crushScore ?? 0) > 100 && (self.crushScore?.crushScore ?? 0) <= 200 {
                    self.crushScoreLabel.text = "😊😎😍🔥"
                }
                else if (self.crushScore?.crushScore ?? 0) > 200 && (self.crushScore?.crushScore ?? 0) <= 400 {
                    self.crushScoreLabel.text = "😊😎😍🔥❤️"
                }
                else if (self.crushScore?.crushScore ?? 0) > 400 {
                    self.crushScoreLabel.text = "😊😎😍🔥❤️👀"
                }
                
            }
            else {
                self.crushScoreLabel.text = "😊"
            }
        }
        
    }
    
    
    let swipingPhotosController = SwipingPhotosController(isCardViewMode: false)
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "HI im a loser hahahahh hahahha"
        label.numberOfLines = 0
        return label
    }()
    
    let crushScoreLabel: UILabel = {
        let label = UILabel()
        label.text = "HI im a loser hahahahh hahahha"
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
        button.setImage(#imageLiteral(resourceName: "infoButton").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
//    lazy var dislikeButton = self.createButton(image: #imageLiteral(resourceName: "dismiss_circle"), selector: #selector(handleDislike))
//    lazy var superLikeButton = self.createButton(image: #imageLiteral(resourceName: "super_like_circle"), selector: #selector(handleDislike))
//    lazy var likeButton = self.createButton(image: #imageLiteral(resourceName: "like_circle"), selector: #selector(handleDislike))
    
    @objc fileprivate func handleDislike() {
        print("Disliking")
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
        self.dismiss(animated: true)
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
        
        let swipingView = swipingPhotosController.view!
        
        scrollView.addSubview(swipingView)
        
        swipingView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width)
        
        scrollView.addSubview(infoLabel)
        infoLabel.anchor(top: swipingView.bottomAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: scrollView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        
        
        view.addSubview(scrollView)
        scrollView.fillSuperview()
        
        scrollView.addSubview(dismissButton)
        dismissButton.anchor(top: swipingView.bottomAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: -25, left: 16, bottom: 16, right: 16), size: .init(width: 50, height: 50))
        
        scrollView.addSubview(bioLabel)
        bioLabel.text = cardViewModel.bio
        bioLabel.anchor(top: infoLabel.bottomAnchor, leading: infoLabel.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 8, left: 0, bottom: 16, right: 16))
        scrollView.addSubview(crushScoreLabel)
        crushScoreLabel.anchor(top: bioLabel.bottomAnchor, leading: bioLabel.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 8, left: 0, bottom: 16, right: 16))
        self.setLabelText()
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

        
        setupLayout()
        
        setupVisualBlurEffectView()
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let  changeY = -scrollView.contentOffset.y
        var width = view.frame.width + changeY * 2
        width = max(view.frame.width, width)
        //changeY is NEGATIVE
        let imageView = swipingPhotosController.view!
        
        imageView.frame = CGRect(x: min(0,-changeY), y: min(0, -changeY), width: width, height: width)
        
    }
    
//
//    @objc fileprivate func handleTapDismiss () {
//        self.dismiss(animated: true)
//    }
}
