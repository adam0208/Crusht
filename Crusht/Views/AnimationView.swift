//
//  AnimationView.swift
//  Crusht
//
//  Created by William Kelly on 4/7/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit

class AnimationView: UIView {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let gradientLayer = CAGradientLayer()
        let leftColor = #colorLiteral(red: 1, green: 0.6745098039, blue: 0.7215686275, alpha: 1)
        let rightColor = #colorLiteral(red: 0.8755432963, green: 0.4065410793, blue: 0, alpha: 1)
        gradientLayer.colors = [leftColor.cgColor, rightColor.cgColor]
        gradientLayer.locations = [0, 1]
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        
        
        gradientLayer.frame = rect
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let logo = UIImageView(image: #imageLiteral(resourceName: "CrushtLogoLiam69!"))
        logo.contentMode = .scaleAspectFit
        addSubview(logo)
        
        logo.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        
        backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        
        
    }
    
    let gradientLayer = CAGradientLayer()
    
    fileprivate func setupGradientLayer() {
        
        let topColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        let bottomColor = #colorLiteral(red: 0.8755432963, green: 0.4065410793, blue: 0, alpha: 1)
        // make sure to user cgColor
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0, 1]
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
