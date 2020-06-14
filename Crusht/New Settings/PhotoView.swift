//
//  PhotoView.swift
//  Crusht
//
//  Created by William Kelly on 6/12/20.
//  Copyright © 2020 William Kelly. All rights reserved.
//

import UIKit

class PhotoView: UIView {
    
     // MARK: - Properties
        
        let image1: UIImageView = {
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.translatesAutoresizingMaskIntoConstraints = false
            return iv
        }()
    
    let image2: UIImageView = {
              let iv = UIImageView()
              iv.contentMode = .scaleAspectFill
              iv.clipsToBounds = true
              iv.translatesAutoresizingMaskIntoConstraints = false
              return iv
          }()
    
    let image3: UIImageView = {
              let iv = UIImageView()
              iv.contentMode = .scaleAspectFill
              iv.clipsToBounds = true
              iv.translatesAutoresizingMaskIntoConstraints = false
              return iv
          }()
        
      
        
        // MARK: - Init
        
        override init(frame: CGRect) {
            super.init(frame: frame)
             let profileImageDimension: CGFloat = 114
            image1.layer.cornerRadius = profileImageDimension / 2
            image2.layer.cornerRadius = profileImageDimension / 2
            image3.layer.cornerRadius = profileImageDimension / 2

                        
            let stack = UIStackView(arrangedSubviews: [image1, image2, image3])
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            stack.spacing = 7
            addSubview(stack)
            stack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 10, left: 7, bottom: 10, right: 7))
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
    }
