//
//  ProfPageTopStackView.swift
//  Crusht
//
//  Created by William Kelly on 12/5/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit

class ProfPageTopStackView: UIStackView {

    let homeButton = UIButton(type: .system)
    let iconLogo = UIImageView(image: #imageLiteral(resourceName: "CrushtLogoLiam"))
    let messageButton = UIButton(type: .system)
    let restView = UIView()
    let moreView = UIView()
    let evenMoreView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        distribution = .fillEqually
        spacing = 0

        //iconLogo.contentMode = .scaleAspectFill
        //messageButton.setImage(#imageLiteral(resourceName: "top_right_messages").withRenderingMode(.alwaysOriginal), for: .normal)
       // homeButton.setImage(#imageLiteral(resourceName: "top_left_profile").withRenderingMode(.alwaysOriginal), for: .normal)
        
        messageButton.titleLabel?.font = UIFont.systemFont(ofSize: 40)
        messageButton.setTitle("💬", for: .normal)
        messageButton.titleLabel?.adjustsFontForContentSizeCategory = true
       
        homeButton.titleLabel?.font = UIFont.systemFont(ofSize: 40)
        homeButton.setTitle("👤", for: .normal)
        homeButton.titleLabel?.adjustsFontForContentSizeCategory = true
        
        [homeButton, moreView, iconLogo, evenMoreView, messageButton].forEach { (v) in
            addArrangedSubview(v)
        }
        
        //        let buttons = [#imageLiteral(resourceName: "CrushtHomIcon"), #imageLiteral(resourceName: "CrushTLogoIcon")].map{ (img) -> UIView in
        //            let button = UIButton(type: .system)
        //            button.setImage(img, for: .normal)
        //            return button
        ////        }
        //
        //        buttons.forEach { (v) in
        //            addArrangedSubview(v)
        //        }
        
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
