//
//  BioCell.swift
//  Crusht
//
//  Created by William Kelly on 3/27/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit

class BioCell: UITableViewCell {

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
        addSubview(textView)
        textView.fillSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(text: String?, textViewDelegate: UITextViewDelegate) {
        textView.delegate = textViewDelegate
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = text
        layer.masksToBounds = true
        layer.cornerRadius = 22
    }
    
    let textView: UITextView = {
        let tv = BioTextView()
        tv.text = "Bio"
        return tv
    }()
}
