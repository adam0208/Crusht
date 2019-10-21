//
//  ReportTextView.swift
//  Crusht
//
//  Created by Santiago Goycoechea on 10/21/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit

class ReportTextView: UITextView, UITextViewDelegate {
    
    override var intrinsicContentSize: CGSize {
        return .init(width: 0, height: 180)
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5);
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func adjustUITextViewHeight(arg : UITextView) {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = false
    }
}
