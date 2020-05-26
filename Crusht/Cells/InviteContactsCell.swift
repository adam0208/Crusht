//
//  InviteContactsCell.swift
//  Crusht
//
//  Created by William Kelly on 2/17/20.
//  Copyright © 2020 William Kelly. All rights reserved.
//

import UIKit

class InviteContactsCell: UITableViewCell {

       var link: InviteController?
            
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            // Kind of cheat and use a hack
            let starButton = UIButton(type: .system)
            starButton.setImage(#imageLiteral(resourceName: "icons8-plus-50"), for: .normal)
            starButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
           starButton.addTarget(self, action: #selector(handleMarkAsFavorite), for: .touchUpInside)
            starButton.tintColor = .red
            accessoryView = starButton
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setup(favoritableContact: FavoritableContact, hasLiked: Bool) {
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
            
        @objc private func handleMarkAsFavorite() {
           // print("Marking as favorite")
           link?.someMethodIWantToCall(cell: self)
       }
        
        
    }
