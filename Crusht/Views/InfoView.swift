//
//  InfoView.swift
//  Crusht
//
//  Created by William Kelly on 6/15/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit

class InfoView: UIView {
    
    let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 200) .isActive = true
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    let infoText: UILabel = {
        let label = UILabel()
        
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    let textView: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        view.backgroundColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
        return view
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
                setupVisualBlurEffectView()
        addSubview(textView)
        
    
        textView.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor, padding: .init(top: 150, left: 15, bottom: 150, right: 15))

        
        let stack = UIStackView(arrangedSubviews: [infoText, closeButton])
        
        stack.spacing = 20
        
        stack.axis = .vertical
        
        textView.addSubview(stack)
        
        stack.anchor(top: textView.topAnchor, leading: textView.leadingAnchor, bottom: textView.bottomAnchor, trailing: textView.trailingAnchor, padding: .init(top: 30, left: 20, bottom: 30, right: 20))
      
        textView.layer.masksToBounds = true
        textView.layer.cornerRadius = 30
        
       bringSubviewToFront(textView)

        textView.alpha = 1.0

        
    }
    
    
    
    fileprivate func setupVisualBlurEffectView() {
        let blurEffect = UIBlurEffect(style: .regular)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        
        addSubview(visualEffectView)
        visualEffectView.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor)
    }
    
    
    @objc fileprivate func handleDismiss() {
        self.removeFromSuperview()
    }

    
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
