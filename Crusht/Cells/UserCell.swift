//
//  UserCell.swift
//  Crusht
//
//  Created by William Kelly on 12/19/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import Firebase
//import Nuke
import SDWebImage

class UserCell: UITableViewCell {

    var message: Message? {
        didSet {
            setupNameAndProfileImage()
            detailTextLabel?.text = message?.text
            guard let seconds = message?.timestamp?.doubleValue else { return }
            
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    private func setupNameAndProfileImage() {
        
        // This is needed to avoid showing the wrong image while the actual one is being downloaded.
        // The problem is caused by cell reuse.
        self.profileImageView.image = nil
        
        guard let uid = message?.chatPartnerId() else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            guard err == nil else { return }
            
            // Should get document uid
            guard let dictionary = snapshot?.data() as [String: AnyObject]? else { return }
            self.textLabel?.text = dictionary["Full Name"] as? String
            guard let profileImageUrl = dictionary["ImageUrl1"] as? String else { return }
            
            let imageUrl = profileImageUrl
            let url = URL(string: imageUrl)
            
          //  Nuke.loadImage(with: url!, into: self.profileImageView)
            
            SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.profileImageView.image = image
            }
        }
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
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        return label
    }()
    
}

