//
//  BioTextView.swift
//  Crusht
//
//  Created by William Kelly on 3/27/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit

class BioTextView: UITextView, UITextViewDelegate {
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5);
        
    }

        func adjustUITextViewHeight(arg : UITextView)
        {
            arg.translatesAutoresizingMaskIntoConstraints = true
            arg.sizeToFit()
            arg.isScrollEnabled = false
        }
        override var intrinsicContentSize: CGSize {
            return .init(width: 0, height: 100)
        }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //300 chars restriction
        return textView.text.count + (text.count - range.length) <= 30
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

    


