//
//  SettingsCells.swift
//  Crusht
//
//  Created by William Kelly on 12/8/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit

class SettingsCells: UITableViewCell {
    
    class SettingsTextField: UITextField {
        override func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.insetBy(dx: 10, dy: 0)
        }
        
        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.insetBy(dx: 10, dy: 0)
        }
        
        override var intrinsicContentSize: CGSize {
        return .init(width: 0, height: 50)
        }
    }
    
    let textField: UITextField = {
        let tf = SettingsTextField()
        tf.placeholder = "Enter Name"
        return tf
    } ()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(textField)
//        layoutMargins = UIEdgeInsets.zero // remove table cell separator margin
//        contentView.layoutMargins.left = 20 // set up left margin to 20
//        contentView.layoutMargins.right = 20
//        contentView.backgroundColor = .clear
//        backgroundColor = .white
        textField.fillSuperview()
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
