//
//  SendMessageButton.swift
//  Crusht
//
//  Created by William Kelly on 12/14/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit

class SendMessageButton: UIButton {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let gradientLayer = CAGradientLayer()
        let leftColor = #colorLiteral(red: 0.968627451, green: 0.7803921569, blue: 0.3450980392, alpha: 1)
        let rightColor = #colorLiteral(red: 0.5843137255, green: 0.8235294118, blue: 0.4196078431, alpha: 1)
        gradientLayer.colors = [leftColor.cgColor, rightColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        
        layer.cornerRadius = rect.height / 2
        clipsToBounds = true
        
        gradientLayer.frame = rect
    }


}
