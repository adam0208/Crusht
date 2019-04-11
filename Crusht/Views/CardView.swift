//
//  CardView.swift
//  Crusht
//
//  Created by William Kelly on 12/5/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import SDWebImage


protocol  CardViewDelegate {
    func  didTapMoreInfo(cardViewModel: CardViewModel)
    func didRemoveCard(cardView: CardView)
    }


class CardView: UIView {
    
    var delegate: CardViewDelegate?
    
    var nextCardView: CardView?
    
    var cardViewModel: CardViewModel! {
        didSet {
            
//            let imageName = cardViewModel.imageUrls.first ?? ""
//
//            if let url = URL(string: imageName) {
//                imageView.sd_setImage(with: url)
//            }
            
            swipingPhotosController.cardViewModel = self.cardViewModel
            
            infoLabel.attributedText = cardViewModel.attributedString
            infoLabel.textAlignment = cardViewModel.textAlignment
            
            (0..<cardViewModel.imageUrls.count).forEach {(_) in
                let barView = UIView()
                barView.backgroundColor = barDeselectedColor
                barsStackView.addArrangedSubview(barView)
            }
            barsStackView.arrangedSubviews.first?.backgroundColor = .white
            
            setupImageIndexObserver ()
            
        }
        
    }
    
    fileprivate func setupImageIndexObserver () {
        cardViewModel.imageIndexObserver = { [weak self] (idx, imageUrl) in
            //print("changing photo")
//            if let url = URL(string: imageUrl ?? "") {
//                self?.imageView.sd_setImage(with: url)
//            }
            
            self?.barsStackView.arrangedSubviews.forEach({ (v) in
                v.backgroundColor = self?.barDeselectedColor
            })
            self?.barsStackView.arrangedSubviews[idx].backgroundColor = .white
        }
    }
    
    //views and Label in correct order
    //fileprivate let imageView = UIImageView(image: #imageLiteral(resourceName: "IMG_0184")) Use page view instead
    fileprivate let swipingPhotosController = SwipingPhotosController(isCardViewMode: true)
    fileprivate let gradentLayer = CAGradientLayer()
    fileprivate let infoLabel = UILabel()
    
    fileprivate let threshold: CGFloat = 100
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action:
            #selector(handleTap)))
    }
    
    //var imageIndex = 0
    fileprivate let barDeselectedColor = UIColor(white: 0, alpha: 0.1)
    
    @objc fileprivate func handleTap(gesture: UITapGestureRecognizer) {
        let taplocation = gesture.location(in: nil)
        let shouldAdvancePhoto = taplocation.x > frame.width / 2 ? true : false
        if shouldAdvancePhoto {
            cardViewModel.advanceToNextPhoto()
        } else {
            cardViewModel.goToPreviousPhoto()
        }
        
    }
    
    fileprivate func setUpGradientLayer() {
        
        gradentLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradentLayer.locations = [0.5,1.0]
        
        layer.addSublayer(gradentLayer)
    }
    
    fileprivate let infoButton: UIButton = {
            let button = UIButton(type: .system)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 40)
            button.setTitle("👤", for: .normal)
            button.backgroundColor = .white
            button.heightAnchor.constraint(equalToConstant: 50)
            button.widthAnchor.constraint(equalToConstant: 50)
            button.layer.cornerRadius = 25
            button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.addTarget(self, action: #selector(presentUserDetailsPage), for: .touchUpInside)
            
            return button
        }()
    
    
    @objc fileprivate func presentUserDetailsPage() {
        //present is missing so we need to do other shit
        //hack solution is using uiapp
        
        //use delegate instead
        
//        let rootviewController = UIApplication.shared.keyWindow?.rootViewController
//        let userDetailsController = UIViewController()
//        userDetailsController.view.backgroundColor = .yellow
//        rootviewController?.present(userDetailsController, animated: true)
        
        delegate?.didTapMoreInfo(cardViewModel: self.cardViewModel)
        
    }
    
    
    fileprivate func setupLayout() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        let swipingPhotosView = swipingPhotosController.view!
        
        addSubview(swipingPhotosView)
        swipingPhotosView.fillSuperview()
        
        //setupBarsStackView()
        
        setUpGradientLayer()
        
        addSubview(infoLabel)
        
        infoLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))
        
        infoLabel.textColor = .white
        infoLabel.numberOfLines = 0
        
        addSubview(infoButton)
        infoButton.anchor(top: nil, leading: nil, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 20, right: 20) , size: .init(width: 50, height: 50))
    }
    
    fileprivate let barsStackView = UIStackView()
    
    fileprivate func setupBarsStackView() {
        addSubview(barsStackView)
        barsStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
        //dummy bars
        
        barsStackView.spacing = 4
        barsStackView.distribution = .fillEqually
        
    }
    override func layoutSubviews() {
        //in here you know what your CardView frame will be
        gradentLayer.frame = self.frame
    }
    
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            superview?.subviews.forEach({ (subview) in
                subview.layer.removeAllAnimations()
            })
        case .changed:
            handleChanged(gesture)
        case .ended:
            handleEnded(gesture)
            //self.locationViewController.fetchUsersFromFirestore()
        default:
            ()
        }
    }
    
    fileprivate func handleChanged(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation( in: nil)
        
        let degrees: CGFloat = translation.x/20
        let angle = degrees * .pi/180
        
        
        let rotationalTransformation = CGAffineTransform(rotationAngle: angle)
        self.transform = rotationalTransformation.translatedBy(x: translation.x, y: translation.y)
        
    }
    
    let locationViewController = LocationMatchViewController()
    
    fileprivate func handleEnded(_ gesture: UIPanGestureRecognizer) {
        //let threshold: CGFloat = 100
        let translationDirection: CGFloat = gesture.translation(in: nil).x > 0 ? 1 : -1
        let shouldDimmisCard = abs(gesture.translation(in: nil).x) > threshold
        
        //hack solution...fix later maybe add the function to the protocal 
        
        if shouldDimmisCard {
        
        guard let locationController = self.delegate as? LocationMatchViewController else { return }
        
        if translationDirection == 1 {
            locationController.handleLike()
        } else {
            locationController.handleDislike()
        }
        } else {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
                self.transform = .identity
            })
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
