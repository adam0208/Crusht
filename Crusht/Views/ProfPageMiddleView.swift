//
//  ProfPageMiddleView.swift
//  Crusht
//
//  Created by William Kelly on 12/5/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//
import UIKit

class ProfPageMiddleView: UIView {
//
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//
//        let gradientLayer = CAGradientLayer()
//        let leftColor = #colorLiteral(red: 1, green: 0.6745098039, blue: 0.7215686275, alpha: 1)
//        let rightColor = #colorLiteral(red: 0.8755432963, green: 0.4065410793, blue: 0, alpha: 1)
//        gradientLayer.colors = [leftColor.cgColor, rightColor.cgColor]
//        gradientLayer.locations = [0, 1]
//
//        self.layer.insertSublayer(gradientLayer, at: 0)
//
//        layer.cornerRadius = 70
//        clipsToBounds = true
//
//        gradientLayer.frame = rect
//    }
    
    //let noPicImage = UIImage(named: "top_left_profile@2xpng") as UIImage!
    
    let selectPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Profile Picture", for: .normal)
        //button.setBackgroundImage(#imageLiteral(resourceName: "top_left_profile"), for: .normal)
        //button.imageView?.contentMode = .scaleAspectFit
        //button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 400).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        button.imageView?.contentMode = .scaleAspectFill
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.layer.cornerRadius = 70
        button.clipsToBounds = true
        return button
    }()
    
    let greetingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //heightAnchor.constraint(equalToConstant: 250).isActive = true
        backgroundColor = .clear
        
        
        let stackView = UIStackView(arrangedSubviews: [selectPhotoButton, greetingLabel])
        addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.anchor(top: nil, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 0, left: 40, bottom: 0, right: 40))
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
    
 //   let gradientLayer = CAGradientLayer()
    
//    fileprivate func setupGradientLayer() {
//
//        let topColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
//        let bottomColor = #colorLiteral(red: 0.8755432963, green: 0.4065410793, blue: 0, alpha: 1)
//        // make sure to user cgColor
//        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
//        gradientLayer.locations = [0, 1]
//
//    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
