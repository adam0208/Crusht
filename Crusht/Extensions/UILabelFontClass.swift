//
//  UILabelFontClass.swift
//  Crusht
//
//  Created by deepak jain on 11/11/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import Foundation
import UIKit

class UILabelFontClass: UILabel {

     var DynamicFontSize: CGFloat = 0 {
        didSet {
            overrideFontSize(FontSize: DynamicFontSize)
        }
    }

    func overrideFontSize(FontSize: CGFloat){
        let fontName = self.font.fontName
        let screenWidth = UIScreen.main.bounds.size.width
        let calculatedFontSize = screenWidth / 375 * FontSize
        self.font = UIFont(name: fontName, size: calculatedFontSize)
    }
}
