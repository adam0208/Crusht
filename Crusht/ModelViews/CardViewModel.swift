//
//  CardViewModel.swift
//  Crusht
//
//  Created by William Kelly on 12/5/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit

protocol ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel
}

class CardViewModel {
    let uid: String
    let imageUrls: [String]
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
    
    init(uid: String, imageNames: [String], attributedString: NSAttributedString, textAlignment: NSTextAlignment) {
        self.uid = uid
        self.imageUrls = imageNames
        self.attributedString = attributedString
        self.textAlignment = textAlignment
    }
    
    fileprivate var imageIndex = 0 {
        didSet {
            let imageUrl = imageUrls[imageIndex]
            //let imnage = UIImage(named: imageName)
            imageIndexObserver?(imageIndex, imageUrl)
        }
    }
    
    var imageIndexObserver: ((Int, String?) -> ())?
    
    func advanceToNextPhoto() {
        imageIndex = min(imageIndex + 1, imageUrls.count - 1)
    }
    func goToPreviousPhoto() {
        imageIndex = max(0, imageIndex - 1)
}
}