//
//  SeniorFivePostsTableViewCell.swift
//  Crusht
//
//  Created by William Kelly on 1/11/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit

class SeniorFivePostLable: UILabel {
    
    override var intrinsicContentSize: CGSize {
        return .init(width: 0, height: 300)
    }
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: 16, dy: 0))
    }
}

class SeniorFivePostsTableViewCell: UITableViewCell {

    //used "tf" cause copy and paste
    
    let label: UILabel = {
        let tf = SeniorFivePostLable()
        tf.text = "Enter Name"
        tf.numberOfLines = 0
        tf.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        return tf
    } ()
    

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(label)
        label.fillSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
