//
//  SchoolTableViewCell.swift
//  Crusht
//
//  Created by William Kelly on 12/15/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class SchoolTableViewCell: UITableViewCell {
    
    var crush: User? {
        didSet {
            setupNameAndProfileImage()
            
            //detailTextLabel?.text = crush?.name
        }
    }

    var link: SchoolCrushController?
    
    
    fileprivate var user: User?
    
    
    let starButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(#imageLiteral(resourceName: "FaveBttn2"), for: .normal)
    button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)

    button.tintColor = .red
        return button
    }()
    
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
        
        accessoryView = starButton
        
        addSubview(starButton)
        addSubview(profileImageView)
        
        starButton.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        starButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        starButton.widthAnchor.constraint(equalToConstant: 48).isActive = true
        starButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        starButton.addTarget(self, action: #selector(handleTapped), for: .touchUpInside)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
    }
    
 
    
    fileprivate func setupNameAndProfileImage() {
           let school = user?.school ?? "I suck a lot"
        //if let uid = ?.chatPartnerId() {
            Firestore.firestore().collection("users").whereField("School", isEqualTo: school).getDocuments { (snapshot, err) in
                
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
    
    
    @objc func handleTapped() {
        link?.hasTappedCrush(cell: self)
        print("CRUSHBUTTONTAPPED")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
