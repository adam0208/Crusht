//
//  BioTextView.swift
//  Crusht
//
//  Created by William Kelly on 3/27/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit

class BioTextView: UITextView, UITextViewDelegate {

        func adjustUITextViewHeight(arg : UITextView)
        {
            arg.translatesAutoresizingMaskIntoConstraints = true
            arg.sizeToFit()
            arg.isScrollEnabled = false
        }
        override var intrinsicContentSize: CGSize {
            return .init(width: 0, height: 100)
        }
    
        }

    


