//
//  SeniorFiveTableViewCell.swift
//  Crusht
//
//  Created by William Kelly on 1/11/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit

class SeniorFiveTextField: UITextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 24, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 24, dy: 0)
    }
    
    override var intrinsicContentSize: CGSize {
        return .init(width: 0, height: 50)
    }
}

class SeniorFiveTableViewCell: UITableViewCell {
    

    let textField: UITextField = {
        let tf = SeniorFiveTextField()
        tf.placeholder = "Enter Name"
        return tf
    } ()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(textField)
        textField.fillSuperview()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
