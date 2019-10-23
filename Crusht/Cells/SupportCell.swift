//
//  SupportCell.swift
//  Crusht
//
//  Created by Santiago Goycoechea on 10/21/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit

class SupportCell: UITableViewCell {
    
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
        addSubview(email)
        email.fillSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let email: UILabel = {
        let label = UILabel()
        
        label.text = "Support Email: info@crusht.co"
        label.font = UIFont.systemFont(ofSize: 15, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        
        label.textColor = .black
        return label
    }()
}
