//
//  ProfPageMidButtonView.swift
//  Crusht
//
//  Created by William Kelly on 12/6/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit

class ProfPageMidButtonView: UIView {

    let findCrushesBttn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Find Crushes", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        button.setTitleColor(.black, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 200) .isActive = true
        button.layer.cornerRadius = 16
        return button
    }()

    let matchByLocationBttm: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Match by Location", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        button.setTitleColor(.black, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 200) .isActive = true
        button.layer.cornerRadius = 16
        
  
        return button
    }()
    
 
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        heightAnchor.constraint(equalToConstant: 160).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [ findCrushesBttn, matchByLocationBttm])
        addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 18
        stackView.anchor(top: nil, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 0, left: 32, bottom: 20, right: 32))
        //stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}
