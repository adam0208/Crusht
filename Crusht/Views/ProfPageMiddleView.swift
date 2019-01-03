//
//  ProfPageMiddleView.swift
//  Crusht
//
//  Created by William Kelly on 12/5/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit

class ProfPageMiddleView: UIView {

    //let noPicImage = UIImage(named: "top_left_profile@2xpng") as UIImage!
    
    let selectPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Profile Picture", for: .normal)
        //button.setBackgroundImage(#imageLiteral(resourceName: "top_left_profile"), for: .normal)
        //button.imageView?.contentMode = .scaleAspectFit
        //button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 230).isActive = true
        button.widthAnchor.constraint(equalToConstant: 80).isActive = true
        button.imageView?.contentMode = .scaleAspectFill

        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        return button
    }()
    
    let matchByLocationBttm: UIButton = {
        //let view = ProfPageMiddleView()
        let button = UIButton(type: .system)
        button.setTitle("Match by Location", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        button.setTitleColor(.black, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 200) .isActive = true
        button.layer.cornerRadius = 16
        return button
    }()
    
    let greetingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.text = "Hey Good Lookin' 😊"
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        heightAnchor.constraint(equalToConstant: 250).isActive = true
        backgroundColor = .clear
        
        let stackView = UIStackView(arrangedSubviews: [selectPhotoButton, greetingLabel])
        addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.anchor(top: nil, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 0, left: 40, bottom: 0, right: 40))
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
    

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    


}
