//
//  LocationMatchBottomButtonsStackView.swift
//  Crusht
//
//  Created by William Kelly on 12/5/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit

class LocationMatchBottomButtonsStackView: UIStackView {

    static func createButton(image: UIImage) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }
    
    let likeBttn: UIButton = {
       let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 60)
        button.setTitle("👍", for: .normal)
        button.backgroundColor = .white
        button.heightAnchor.constraint(equalToConstant: 50)
        button.widthAnchor.constraint(equalToConstant: 50)
        button.layer.cornerRadius = 50
        button.titleLabel?.adjustsFontForContentSizeCategory = true

       return button
    }()
    
    let disLikeBttn: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 60)
        button.setTitle("👎", for: .normal)
        button.backgroundColor = .white
        button.heightAnchor.constraint(equalToConstant: 50)
        button.widthAnchor.constraint(equalToConstant: 50)
        button.layer.cornerRadius = 50
        button.titleLabel?.adjustsFontForContentSizeCategory = true


        //button.layer.masksToBounds = true
        return button
    }()
    
    
    let refreshButton = createButton(image: #imageLiteral(resourceName: "refresh_circle"))
    let dislikeButton = createButton(image: #imageLiteral(resourceName: "dismiss_circle"))
    let superLikeButton = createButton(image: #imageLiteral(resourceName: "super_like_circle"))
    let likeButton = createButton(image: #imageLiteral(resourceName: "like_circle"))
    let specialButton = createButton(image: #imageLiteral(resourceName: "boost_circle"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        distribution = .fillEqually
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        [refreshButton, disLikeBttn, likeBttn].forEach { (button) in
            self.addArrangedSubview(button)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
