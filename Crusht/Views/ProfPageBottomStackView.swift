//
//  ProfPageBottomStackView.swift
//  Crusht
//
//  Created by William Kelly on 12/5/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit

class ProfPageBottomStackView: UIStackView {
    
    let restView = UIView()
    let evenMoreView = UIView()
    let moreView = UIView()
//
//    let seniorFive:  UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Top 5's", for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .medium)
//        button.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
//        button.setTitleColor(.black, for: .normal)
//        //button.heightAnchor.constraint(equalToConstant: 40).isActive = true
//        button.widthAnchor.constraint(equalToConstant: 100) .isActive = true
//        button.layer.cornerRadius = 16
//        return button
//
//    }()
    
    let findCrushesBttn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Peer Crushin'", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 200) .isActive = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2.0
        return button
    }()
    
    let matchByLocationBttm: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Location Cruhsin", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 200) .isActive = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2.0
  
        
        return button
    }()
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        distribution = .fillEqually

        //seniorFive.setImage(#imageLiteral(resourceName: "SeniorFiveIcon.png").withRenderingMode(.alwaysOriginal), for: .normal)
        
        
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
        [findCrushesBttn, matchByLocationBttm].forEach { (v) in
            addArrangedSubview(v)
        }
        
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
