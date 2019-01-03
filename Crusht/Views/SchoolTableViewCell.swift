//
//  SchoolTableViewCell.swift
//  Crusht
//
//  Created by William Kelly on 12/15/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit

class SchoolTableViewCell: UITableViewCell {

    var link: FindCrushesTableViewController?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let starButton = UIButton(type: .system)
        starButton.setImage(#imageLiteral(resourceName: "FaveBttn2"), for: .normal)
        starButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        starButton.tintColor = .red
        starButton.addTarget(self, action: #selector(handleMarkAsFavorite), for: .touchUpInside)
        
        accessoryView = starButton
    }
    
    @objc fileprivate func handleMarkAsFavorite() {
        //        print("Marking as favorite")
        link?.someMethodIWantToCall(cell: self)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
