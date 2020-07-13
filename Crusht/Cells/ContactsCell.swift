//
//  ContactsCell.swift
//  Crusht
//
//  Created by William Kelly on 12/11/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import Contacts
import SDWebImage

class ContactsCell: UITableViewCell {
    var link: ContactsController?
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryView = starButton
        addSubview(starButton)
        addSubview(profileImageView)
          
          starButton.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
          starButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
          starButton.widthAnchor.constraint(equalToConstant: 48).isActive = true
          starButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        // Kind of cheat and use a hack
        starButton.addTarget(self, action: #selector(handleMarkAsFavorite), for: .touchUpInside)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(favoritableContact: FavoritableContact, hasLiked: Bool) {
        profileImageView.isHidden = true
        selectionStyle = .none
        textLabel?.text = favoritableContact.name
        textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        let phoneString = favoritableContact.phoneCell
                 let phoneIDStripped = phoneString.replacingOccurrences(of: " ", with: "")
                 let phoneNoParen = phoneIDStripped.replacingOccurrences(of: "(", with: "")
                 let phoneNoParen2 = phoneNoParen.replacingOccurrences(of: ")", with: "")
                 let phoneNoDash = phoneNoParen2.replacingOccurrences(of: "-", with: "")
        detailTextLabel?.text = phoneNoDash
        accessoryView?.tintColor = hasLiked ? .red : #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1)
    }
    
    func setup2(crush: User, hasFavorited: Bool) {
        textLabel?.text = "\(crush.firstName ?? "") \(crush.lastName ?? "")"
        
        // This is needed to avoid showing the wrong image while the actual one is being downloaded.
        // The problem is caused by cell reuse.
        self.profileImageView.image = nil
        
        let imageUrl = crush.imageUrl1!
        let url = URL(string: imageUrl)
     //   Nuke.loadImage(with: url!, into: self.profileImageView)
        SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
            self.profileImageView.image = image
        }
        accessoryView?.isHidden = false
        accessoryView?.tintColor = hasFavorited ? .red : #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1)
    }
    
        
    @objc private func handleMarkAsFavorite() {
       // print("Marking as favorite")
       link?.someMethodIWantToCall(cell: self)
   }
    
    let starButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "heartIcon3Crusht.png"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)

        button.tintColor = .red
        return button
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
}

