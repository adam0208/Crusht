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
        

            //        backgroundColor = .red
            
            // kind of cheat and use a hack
            let starButton = UIButton(type: .system)
            starButton.setImage(#imageLiteral(resourceName: "heartIcon3Crusht"), for: .normal)
            starButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            //starButton.tintColor = .red
            starButton.addTarget(self, action: #selector(handleMarkAsFavorite), for: .touchUpInside)
            
            accessoryView = starButton
        }
    
//    override func layoutSubviews() {
//       super.layoutSubviews()
//
//        contentView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: 20)
//        contentView.backgroundColor = #colorLiteral(red: 0.7607843137, green: 0.9294117647, blue: 0.6784313725, alpha: 1)
//
//    }
    
        @objc private func handleMarkAsFavorite() {
            //        print("Marking as favorite")
            link?.someMethodIWantToCall(cell: self)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }

