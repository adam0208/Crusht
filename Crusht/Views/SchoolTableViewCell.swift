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

    var link: SchoolCrushController?
    
    var schoolArray = [String]()
    
    fileprivate var user: User?
    
    var nameText: UILabel = {
        let text = UILabel()
        text.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        text.text = "Loading Names"
        return text
    }()
    
    let starButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(#imageLiteral(resourceName: "FaveBttn2"), for: .normal)
    button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
    
    button.tintColor = .red
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryView = starButton
        
        addSubview(starButton)
        addSubview(nameText)
        nameText.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: nil)
        starButton.anchor(top: self.topAnchor, leading: nil, bottom: self.bottomAnchor, trailing: self.trailingAnchor)
        starButton.addTarget(self, action: #selector(handleTapped), for: .touchUpInside)
        
        
    }
    
    @objc func handleTapped() {
        link?.hasTappedCrush(cell: self)
        print("CRUSHBUTTONTAPPED")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
