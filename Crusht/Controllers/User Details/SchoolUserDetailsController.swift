//
//  SchoolUserDetailsController.swift
//  Crusht
//
//  Created by William Kelly on 1/31/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import SDWebImage

class SchoolUserDetailsController: UIViewController {
    
    var user: User? {
        didSet {
            
            loadUserPhotos()
        
            bioLabel.text = user?.bio
            nameLabel.text = user?.name
            
//            if (user?.crushScore!)! > 50 && (user?.crushScore!)! <= 100 {
//            scoreText.text = "😊"
//            }
//            else if (user?.crushScore!)! > 100 && (user?.crushScore!)! <= 200 {
//                scoreText.text = "😊😎"
//            }
//            else if (user?.crushScore!)! > 200 && (user?.crushScore!)! <= 400 {
//                scoreText.text = "😊😎😍"
//            }
//            else if (user?.crushScore!)! > 400 && (user?.crushScore!)! <= 800 {
//                scoreText.text = "😊😎😍🔥"
//            }
          //  else {
                scoreText.text = "😬"
            }
        //}
        
    }
    
    //UI
    
    let profPhoto: UIImageView = {
        let image = UIImageView()
        image.heightAnchor.constraint(equalToConstant: 200)
        image.widthAnchor.constraint(equalToConstant: 130)
        return image
    }()
    
    let scoreText: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        label.textAlignment = .center
//        label.heightAnchor.constraint(equalToConstant: 40)

        return label
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        label.textAlignment = .center
//        label.heightAnchor.constraint(equalToConstant: 40)
        
        return label
    }()
    
    let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "infoButton").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    fileprivate func loadUserPhotos() {
        guard let imageUrl = user?.imageUrl1, let url = URL(string: imageUrl) else {return}
        SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
//            self.profPhoto.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            self.profPhoto.image = image
        }
        //self.user?.imageUrl1
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserPhotos()
        
        bioLabel.text = user?.bio
        nameLabel.text = user?.name
        scoreText.text = "😬"
        
        navigationController?.isNavigationBarHidden = true
        
        view.backgroundColor = .white
        
        let stack = UIStackView(arrangedSubviews: [profPhoto, nameLabel, scoreText, bioLabel])
        stack.axis = .vertical
        
        view.addSubview(stack)
        
        stack.spacing = 10
        
        stack.fillSuperview()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))

        
        view.addGestureRecognizer(tap)
        
//                dismissButton.anchor(top: sta.bottomAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: -25, left: 16, bottom: 16, right: 16), size: .init(width: 50, height: 50))
        
        
    }

    @objc fileprivate func handleDismiss() {
        dismiss(animated: true)
    }

}
