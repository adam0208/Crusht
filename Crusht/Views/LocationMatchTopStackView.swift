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
    
    let collegeOnlySwitch: UISwitch = {
        let button = UISwitch()
        button.isOn = false
        //button.thumbTintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        button.onTintColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        return button
    }()
    
    let collegeLabel: UILabel = {
        let label = UILabel()
        label.text = "Only Your School"
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        distribution = .fillEqually
        backgroundColor = .white
        iconLogo.contentMode = .scaleAspectFit
        let stackview = UIStackView(arrangedSubviews: [collegeLabel, collegeOnlySwitch])
        stackview.axis = .horizontal
        //iconLogo.backgroundColor = .white
//        homeButton.setImage(#imageLiteral(resourceName: "ChrushtHomeIcon4").withRenderingMode(.alwaysOriginal), for: .normal)
        //homeButton.backgroundColor = .white
        homeButton.setTitle("👈", for: .normal)
        homeButton.titleLabel?.font = UIFont.systemFont(ofSize: 50)
        homeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        [homeButton, stackview].forEach { (v) in
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
