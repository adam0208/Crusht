//
//  ContactsTextCell.swift
//  Crusht
//
//  Created by Santiago Goycoechea on 10/21/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit

class ContactsTextCell: UITableViewCell {
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            frame.origin.x += 10
            frame.size.width -= 2 * 12
            super.frame = frame
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(privacyText)
        selectionStyle = .none
        privacyText.fillSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let privacyText: UILabel = {
        let label = UILabel()
        label.text = "If one of your contacts doesn't have Crusht and you heart them, an anonymous message will be sent to their device informing them that \"someone\" has a crush on them."
        label.font = UIFont.systemFont(ofSize: 15, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
}
