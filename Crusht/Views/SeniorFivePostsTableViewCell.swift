//
//  SeniorFivePostsTableViewCell.swift
//  Crusht
//
//  Created by William Kelly on 1/11/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit

class SeniorFivePostLable: UILabel {
    
    override var intrinsicContentSize: CGSize {
        return .init(width: 0, height: 300)
    }
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: 16, dy: 0))
    }
}

class SeniorFivePostsTableViewCell: UITableViewCell {

    //used "tf" cause copy and paste
    
    var crush: Crushes? {
        didSet {
            //setupNameAndProfileImage()
            
            label.text = "\(crush?.crush1 ?? "YOU SUCK")\n\(crush?.crush2 ?? "YOU SUCK")\n\(crush?.crush3 ?? "YOU SUCK")\n\(crush?.crush4 ?? "YOU SUCK")\n\(crush?.crush5 ?? "YOU SUCK")\n\n\(crush?.comments ?? "YOU SUCK")"
            
            if let seconds = crush?.timestamp?.doubleValue {
                let timestampDate = Date(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timestampDate)
            }
            
            
        }
    }
    
    let timeLabel: UILabel = {
        let label = UILabel()
        //        label.text = "HH:MM:SS"
        //label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        //label.translatesAutoresizingMaskIntoConstraints = false
         label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        return label
    }()
    
    let label: UILabel = {
        let tf = SeniorFivePostLable()
        tf.text = "Enter Name"
        tf.numberOfLines = 0
        tf.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        return tf
    } ()
    
    let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Like", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        //button.addTarget(self, action: #selector(<#T##@objc method#>), for: .touchUpInside)
        return button
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(likeButton)
        let stack = UIStackView(arrangedSubviews: [timeLabel, label])
        addSubview(stack)
       stack.axis = .vertical
        likeButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        
       stack.fillSuperview()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
