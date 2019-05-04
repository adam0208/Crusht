//
//  Venue.swift
//  Crusht
//
//  Created by William Kelly on 4/20/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Venue: NSObject {
    
    var venueName: String?
    var venueCity: String?
    var venuePhotoUrl: String?
    
    var venueLat: String?
    var venueLong: String?
    
    var name: String
    
    init(dictionary: [String: Any]) {
        self.venueName = dictionary["venueName"] as? String ?? ""
        self.venueCity = dictionary["venueCity"] as? String ?? ""
        self.venuePhotoUrl = dictionary["venuePhotoUrl"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
      
        
    }
    

    
}
