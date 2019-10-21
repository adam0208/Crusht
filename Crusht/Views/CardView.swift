//
//  CardView.swift
//  Crusht
//
//  Created by William Kelly on 12/5/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import SDWebImage

protocol CardViewDelegate {
    func didTapMoreInfo(cardViewModel: CardViewModel)
    func didRemoveCard(cardView: CardView)
}

class CardView: UIView {
    private let threshold: CGFloat = 100
    private let swipingPhotosController = SwipingPhotosController(isCardViewMode: true)
    private let gradentLayer = CAGradientLayer()
    private let infoLabel = UILabel()
    private let barsStackView = UIStackView()
    private let barDeselectedColor = UIColor(white: 0, alpha: 0.1)
    let locationViewController = LocationMatchViewController()
    
    var delegate: CardViewDelegate?
    var nextCardView: CardView?
    
    var cardViewModel: CardViewModel! {
        didSet {
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
    
    var lastCardView: CardView {
        if let nextCardView = nextCardView {
            return nextCardView.lastCardView
        }
        return self
    }
    
    // MARK: - Life Cycle Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        // In here you know what your CardView frame will be
        gradentLayer.frame = self.frame
    }
    
    // MARK: - Logic
    
    private func setupImageIndexObserver () {
        cardViewModel.imageIndexObserver = { [weak self] (idx, imageUrl) in
            self?.barsStackView.arrangedSubviews.forEach { (v) in
                v.backgroundColor = self?.barDeselectedColor
            }
            self?.barsStackView.arrangedSubviews[idx].backgroundColor = .white
        }
    }
    
    @objc private func handleTap(gesture: UITapGestureRecognizer) {
        let taplocation = gesture.location(in: nil)
        let shouldAdvancePhoto = taplocation.x > frame.width / 2
        if shouldAdvancePhoto {
            cardViewModel.advanceToNextPhoto()
        } else {
            cardViewModel.goToPreviousPhoto()
        }
    }
    
    private func handleEnded(_ gesture: UIPanGestureRecognizer) {
        let translationDirection: CGFloat = gesture.translation(in: nil).x > 0 ? 1 : -1
        let shouldDimmisCard = abs(gesture.translation(in: nil).x) > threshold
        
        // Hack solution...fix later maybe add the function to the protocal
        
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
    
    @objc private func presentUserDetailsPage() {
        // Present is missing so we need to do other shit
        // Hack solution is using uiapp
        // Use delegate instead
        delegate?.didTapMoreInfo(cardViewModel: self.cardViewModel)
    }
    
    @objc private func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            superview?.subviews.forEach { (subview) in
                subview.layer.removeAllAnimations()
            }
        case .changed:
            handleChanged(gesture)
        case .ended:
            handleEnded(gesture)
        default:
            break
        }
    }
    
    private func handleChanged(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation( in: nil)
        let degrees: CGFloat = translation.x/20
        let angle = degrees * .pi/180
        let rotationalTransformation = CGAffineTransform(rotationAngle: angle)
        self.transform = rotationalTransformation.translatedBy(x: translation.x, y: translation.y)
    }
    
    // MARK: - User Interface
    
    private func initializeUI() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        let swipingPhotosView = swipingPhotosController.view!
        addSubview(swipingPhotosView)
        swipingPhotosView.fillSuperview()
        setUpGradientLayer()
        
        addSubview(infoButton)
        infoButton.anchor(top: nil,
                          leading: nil,
                          bottom: bottomAnchor,
                          trailing: trailingAnchor,
                          padding: .init(top: 0, left: 0, bottom: 20, right: 5) , size: .init(width: 50, height: 50))
        
        addSubview(infoLabel)
        infoLabel.anchor(top: nil,
                         leading: leadingAnchor,
                         bottom: bottomAnchor,
                         trailing: infoButton.leadingAnchor,
                         padding: .init(top: 0, left: 16, bottom: 16, right: 16))
        
        infoLabel.textColor = .white
        infoLabel.numberOfLines = 0
    }
    
    private func setUpGradientLayer() {
        gradentLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradentLayer.locations = [0.5,1.0]
        layer.addSublayer(gradentLayer)
    }
    
    private func setupBarsStackView() {
        addSubview(barsStackView)
        barsStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
        //Dummy bars
        barsStackView.spacing = 4
        barsStackView.distribution = .fillEqually
    }
    
    private let infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(#imageLiteral(resourceName: "icons8-male-user-filled-50").withRenderingMode(.alwaysOriginal), for: .normal)

        button.backgroundColor = .white
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.addTarget(self, action: #selector(presentUserDetailsPage), for: .touchUpInside)

        return button
    }()
}
