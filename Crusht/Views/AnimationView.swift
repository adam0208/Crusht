//
//  AnimationView.swift
//  Crusht
//
//  Created by William Kelly on 4/7/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit

class AnimationView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let logo = UIImageView(image: #imageLiteral(resourceName: "CrushtLogoLiam"))
        logo.contentMode = .scaleAspectFit
        addSubview(logo)
        
        logo.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        
        backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
