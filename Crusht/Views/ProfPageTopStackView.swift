//
//  ProfPageTopStackView.swift
//  Crusht
//
//  Created by William Kelly on 12/5/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit

class ProfPageTopStackView: UIStackView {

    let homeButton = UIButton()
    let iconLogo = UIImageView(image: #imageLiteral(resourceName: "CrushtLogoLiam"))
    let messageButton = UIButton(type: .system)
    let restView = UIView()
    let moreView = UIView()
    let evenMoreView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        distribution = .fillEqually
        spacing = 0

        //iconLogo.contentMode = .scaleAspectFill
        messageButton.setImage(#imageLiteral(resourceName: "icons8-communication-60").withRenderingMode(.alwaysOriginal), for: .normal)
        homeButton.setImage(#imageLiteral(resourceName: "SettingsIconCrusht-1").withRenderingMode(.alwaysOriginal), for: .normal)
       homeButton.layer.cornerRadius = 30
        homeButton.clipsToBounds = true
        
        
        [homeButton, moreView, UIView(), UIView(), evenMoreView, messageButton].forEach { (v) in
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
