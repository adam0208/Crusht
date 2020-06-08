//
//  LocationMatchTopStackView.swift
//  Crusht
//
//  Created by William Kelly on 12/5/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit

class LocationMatchTopStackView: UIStackView {
    let homeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    
    let collegeOnlySwitch: UISwitch = {
        let button = UISwitch()
        button.isOn = false
        button.onTintColor = #colorLiteral(red: 1, green: 0, blue: 0.6713966727, alpha: 1)
        return button
    }()
    
    let collegeLabel: UILabel = {
        let label = UILabel()
        label.text = "Only Your School  "
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        distribution = .fillEqually
        
        addSubview(collegeOnlySwitch)
        collegeOnlySwitch.anchor(top: self.topAnchor,
                                 leading: nil,
                                 bottom: self.bottomAnchor,
                                 trailing: self.trailingAnchor,
                                 padding: .init(top: 11, left: 0, bottom: 0, right: 0))
        
        addSubview(collegeLabel)
        collegeLabel.anchor(top: self.topAnchor,
                            leading: nil,
                            bottom: self.bottomAnchor,
                            trailing: collegeOnlySwitch.leadingAnchor)
        
        homeButton.setImage(#imageLiteral(resourceName: "icons8-back-filled-30-2").withRenderingMode(.alwaysOriginal), for: .normal)
        addSubview(homeButton)
        homeButton.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: nil)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
