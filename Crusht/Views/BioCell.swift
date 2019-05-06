//
//  BioCell.swift
//  Crusht
//
//  Created by William Kelly on 3/27/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit

class BioCell: UITableViewCell {
    
 // let textView = BioTextView()
    
    let textView: UITextView = {
        let tv = BioTextView()
        tv.text = "Bio"
        
        return tv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
       
        addSubview(textView)
        //        layoutMargins = UIEdgeInsets.zero // remove table cell separator margin
        //        contentView.layoutMargins.left = 20 // set up left margin to 20
        //        contentView.layoutMargins.right = 20
        //        contentView.backgroundColor = .clear
        //        backgroundColor = .white
        textView.fillSuperview()
    }
    
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
    
 
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
