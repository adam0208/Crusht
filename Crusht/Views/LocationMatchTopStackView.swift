//
//  LocationMatchTopStackView.swift
//  Crusht
//
//  Created by William Kelly on 12/5/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit

class LocationMatchTopStackView: UIStackView {

    let homeButton = UIButton(type: .system)
    let iconLogo = UIImageView(image: #imageLiteral(resourceName: "CrushTLogoIcon"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        distribution = .fillEqually
        backgroundColor = .white
        iconLogo.contentMode = .scaleAspectFit
        //iconLogo.backgroundColor = .white
        homeButton.setImage(#imageLiteral(resourceName: "ChrushtHomeIcon4").withRenderingMode(.alwaysOriginal), for: .normal)
        //homeButton.backgroundColor = .white
        [homeButton, iconLogo, UIView()].forEach { (v) in
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
