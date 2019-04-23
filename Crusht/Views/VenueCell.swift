//
//  VenueCell.swift
//  Crusht
//
//  Created by William Kelly on 4/20/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase

class VenueCell: UITableViewCell {
       
     var venue: Venue? {
        didSet {
            setupNameAndProfileImage()
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
      
        addSubview(profileImageView)
        
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
    }
    
    fileprivate func setupNameAndProfileImage() {
        //if let uid = ?.chatPartnerId() {
        Firestore.firestore().collection("venues").whereField("venueName", isEqualTo: "Mary Ann's").getDocuments { (snapshot, err) in
            
            if let err = err {
                print("FAILLLLLLLLL", err)
            }
            
            snapshot?.documents.forEach({ (documentSnapshot) in
                if let dictionary = documentSnapshot.data() as [String: AnyObject]? {
                    
                    self.textLabel?.text = dictionary["Full Name"] as? String
                    self.detailTextLabel?.text = dictionary["School"] as? String
                    
                    if let profileImageUrl = dictionary["ImageUrl1"] as? String {
                        self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
                    }
                    
                }
                
            })
            
        }
        
    }
    

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
