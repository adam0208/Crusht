//
//  Advertiser.swift
//  Crusht
//
//  Created by William Kelly on 12/5/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import Foundation

import UIKit

struct Advertiser : ProducesCardViewModel {
    let title: String
    let brandName: String
    let posterPhotoName: String
    
    
    
    func toCardViewModel() -> CardViewModel {
        
        let attributedString = NSMutableAttributedString(string: title, attributes: [.font: UIFont.systemFont(ofSize: 34, weight: .heavy)])
        attributedString.append(NSAttributedString(string: "\n" + brandName, attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .bold)]))
        
        return CardViewModel(uid: "", bio: "", phone: "", imageNames: [posterPhotoName], attributedString: attributedString, textAlignment: .center)
        
    }
    
}
