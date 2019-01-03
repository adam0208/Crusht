//
//  UserDetailsController.swift
//  Crusht
//
//  Created by William Kelly on 12/9/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit

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
    
    
    let swipingPhotosController = SwipingPhotosController(isCardViewMode: false)
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "HI im a loser hahahahh hahahha"
        label.numberOfLines = 0
        return label
    }()
    
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "infoButton").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    lazy var dislikeButton = self.createButton(image: #imageLiteral(resourceName: "dismiss_circle"), selector: #selector(handleDislike))
    lazy var superLikeButton = self.createButton(image: #imageLiteral(resourceName: "super_like_circle"), selector: #selector(handleDislike))
    lazy var likeButton = self.createButton(image: #imageLiteral(resourceName: "like_circle"), selector: #selector(handleDislike))
    
    @objc fileprivate func handleDislike() {
        print("Disliking")
    }
    
    fileprivate func createButton(image: UIImage, selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }
    
    @objc fileprivate func handleDismiss() {
        self.dismiss(animated: true)
    }
    
    fileprivate func setupBottomControls() {
        let stackView = UIStackView(arrangedSubviews: [dislikeButton, superLikeButton, likeButton])
        stackView.distribution = .fillEqually
        stackView.spacing = -32
        view.addSubview(stackView)
        stackView.anchor(top: nil, leading: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 300, height: 80))
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

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
        
        setupBottomControls()
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
