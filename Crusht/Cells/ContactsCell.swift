//
//  ContactsCell.swift
//  Crusht
//
//  Created by William Kelly on 12/11/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import Contacts

class ContactsCell: UITableViewCell {
    var link: FindCrushesTableViewController?
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Kind of cheat and use a hack
        let starButton = UIButton(type: .system)
        starButton.setImage(#imageLiteral(resourceName: "heartIcon3Crusht"), for: .normal)
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
        detailTextLabel?.text = favoritableContact.contact.phoneNumbers.first?.value.stringValue
        accessoryView?.tintColor = hasLiked ? .red : #colorLiteral(red: 0.8669986129, green: 0.8669986129, blue: 0.8669986129, alpha: 1)
    }
        
    @objc private func handleMarkAsFavorite() {
       // print("Marking as favorite")
       link?.someMethodIWantToCall(cell: self)
   }
}

