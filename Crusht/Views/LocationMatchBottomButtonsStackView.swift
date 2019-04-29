//
//  LocationMatchBottomButtonsStackView.swift
//  Crusht
//
//  Created by William Kelly on 12/5/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit

class LocationMatchBottomButtonsStackView: UIStackView {

    static func createButton(image: UIImage) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }
    
//    let likeBttn: UIButton = {
//       let button = UIButton(type: .system)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 60)
//        button.setTitle("👍", for: .normal)
//        button.backgroundColor = .white
//        button.heightAnchor.constraint(equalToConstant: 50)
//        button.widthAnchor.constraint(equalToConstant: 50)
//        button.layer.cornerRadius = 50
//        button.titleLabel?.adjustsFontForContentSizeCategory = true
//
//       return button
//    }()
    
//    let disLikeBttn: UIButton = {
//        let button = UIButton(type: .system)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 60)
//        button.setTitle("👎", for: .normal)
//        button.backgroundColor = .white
//        button.heightAnchor.constraint(equalToConstant: 50)
//        button.widthAnchor.constraint(equalToConstant: 50)
//        button.layer.cornerRadius = 50
//        button.titleLabel?.adjustsFontForContentSizeCategory = true
//
//
//        //button.layer.masksToBounds = true
//        return button
//    }()
    
//    let refreshButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 60)
//        button.setTitle("♻️", for: .normal)
//        button.backgroundColor = .white
//        button.heightAnchor.constraint(equalToConstant: 50)
//        button.widthAnchor.constraint(equalToConstant: 50)
//        button.layer.cornerRadius = 50
//        button.titleLabel?.adjustsFontForContentSizeCategory = true
//
//
//        //button.layer.masksToBounds = true
//        return button
//    }()
    

    
    let refreshButton = createButton(image: #imageLiteral(resourceName: "icons8-refresh-30"))
    let disLikeBttn = createButton(image: #imageLiteral(resourceName: "icons8-cancel-30"))
    let likeBttn = createButton(image: #imageLiteral(resourceName: "icons8-love-30"))
    let reportButton = createButton(image: #imageLiteral(resourceName: "icons8-box-important-30"))
    let blueView = UIView()
    let blue = UIView()
    let moreblue = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        distribution = .fillEqually
        heightAnchor.constraint(equalToConstant: 30).isActive = true
        blueView.backgroundColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
        blue.backgroundColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
        moreblue.backgroundColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
        spacing = 0
        
        
        
        [refreshButton, disLikeBttn, likeBttn, reportButton ].forEach { (button) in
            self.addArrangedSubview(button)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
