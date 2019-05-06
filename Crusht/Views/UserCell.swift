//
//  UserCell.swift
//  Crusht
//
//  Created by William Kelly on 12/19/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class UserCell: UITableViewCell {

    var message: Message? {
        didSet {
            setupNameAndProfileImage()
            
            
        
            detailTextLabel?.text = message?.text
                
          
            if let seconds = message?.timestamp?.doubleValue {
            let timestampDate = Date(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
                let elapsedTimeInSeconds = NSDate().timeIntervalSince(timestampDate)
        
                let secondInDays: TimeInterval = 60 * 60 * 24
        
        if elapsedTimeInSeconds > 7 * secondInDays {
        dateFormatter.dateFormat = "MM/dd/yy"
        } else if elapsedTimeInSeconds > secondInDays {
        dateFormatter.dateFormat = "EEE"
        }
        
                timeLabel.text = dateFormatter.string(from: timestampDate)
            }
            
            
        }
    }
    
    fileprivate func setupNameAndProfileImage() {
        
        if let uid = message?.chatPartnerId() {
            Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
             
                if let err = err {
                    return
                }
                //should get document uid
                //snapshot?.data().forEach({ (documentSnapshot) in
                if let dictionary = snapshot?.data() as [String: AnyObject]?
                    //let user = User(dictionary: userDictionary)
//                if let dictionary = snapshot.value as? [String: AnyObject]
                 {
                    self.textLabel?.text = dictionary["Full Name"] as? String
                    
                    if let profileImageUrl = dictionary["ImageUrl1"] as? String {
                        let imageUrl = profileImageUrl
                        let url = URL(string: imageUrl)
                        SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                            self.profileImageView.image = image
                            }
                        }
                    }
                //                user.name = dictionary["name"]
            }
            
            }
        }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        //        label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        //ios 9 constraint anchors
        //need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        //need x,y,width,height anchors
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -12).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

