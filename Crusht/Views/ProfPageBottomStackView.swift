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
   
    let seniorFive = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = #colorLiteral(red: 1, green: 0.6745098039, blue: 0.7215686275, alpha: 1)
        distribution = .fillEqually
        evenMoreView.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        seniorFive.setImage(#imageLiteral(resourceName: "SeniorFiveIcon.png").withRenderingMode(.alwaysOriginal), for: .normal)
        
        
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        
 

        [evenMoreView, restView, seniorFive].forEach { (v) in
            addArrangedSubview(v)
        }
        
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
