//
//  LocationMatchBottomButtonsStackView.swift
//  Crusht
//
//  Created by William Kelly on 12/5/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit

class LocationMatchBottomButtonsStackView: UIStackView {
    let refreshButton = createButton(image: #imageLiteral(resourceName: "icons8-refresh-30"))
    let disLikeBttn = createButton(image: #imageLiteral(resourceName: "icons8-cancel-31"))
    let likeBttn = createButton(image: #imageLiteral(resourceName: "icons8-love-30"))
    let reportButton = createButton(image: #imageLiteral(resourceName: "icons8-box-important-30-2"))
    let blueView = UIView()
    let blue = UIView()
    let moreblue = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        distribution = .fillEqually
        heightAnchor.constraint(equalToConstant: 30).isActive = true
      
        spacing = 0
        
        [refreshButton, disLikeBttn, likeBttn, reportButton ].forEach { (button) in
            self.addArrangedSubview(button)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static private func createButton(image: UIImage) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }
}
