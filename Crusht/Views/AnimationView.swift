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
        let leftColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        let rightColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
        gradientLayer.colors = [leftColor.cgColor, rightColor.cgColor]
        gradientLayer.locations = [0, 1]
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        
        
        gradientLayer.frame = rect
    }
    
     let logo = UIImageView(image: #imageLiteral(resourceName: "CrushtLogoLiam69!"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
       
        logo.contentMode = .scaleAspectFit
        addSubview(logo)
        
        logo.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        
        logo.transform = CGAffineTransform(translationX: 0, y: 0)
        
       jumpButtonAnimation(sender: logo)
        
    }
    
    func jumpButtonAnimation(sender: UIImageView) {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = NSNumber(value: 1.1)
        animation.duration = 1
        animation.repeatCount = 5
        animation.autoreverses = true
        sender.layer.add(animation, forKey: nil)
    }
    
    let gradientLayer = CAGradientLayer()
    
    fileprivate func setupGradientLayer() {
        
        let topColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        let bottomColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
        // make sure to user cgColor
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0, 1]
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
