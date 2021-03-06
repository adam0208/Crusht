//
//  CurrentUserDetailsNoReportController.swift
//  Crusht
//
//  Created by William Kelly on 5/5/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class CurrentUserDetailsNoReportController: UIViewController, UIScrollViewDelegate {
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
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let swipingView = swipingPhotosController.view!
        swipingView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width + extraSwipingHeight)
    }
    
    // MARK: - Logic
    
    @objc private func handleDismiss() {
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.popToRootViewController(animated: true)
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
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = false
        
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
        scrollView.addSubview(crushScoreLabel)
        
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
    
    private let crushScoreLabel: UILabel = {
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
