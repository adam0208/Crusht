//
//  SchoolCrushes.swift
//  Crusht
//
//  Created by William Kelly on 1/18/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import Foundation
import UIKit

class SchoolCrushes: NSObject {
    var name: String?
    var age: Int?
    var school: String?
    var imageUrl1: String?
    var uid: String?
    
    init(dictionary: [String: Any]) {
        //initialize our user stuff
        
        //let age = dictionary["Age"] as? Int
        self.name = dictionary["Full Name"] as? String ?? ""
        self.age = dictionary["Age"] as? Int
        self.school = dictionary["School"] as? String ?? ""
        self.imageUrl1 = dictionary["ImageUrl1"] as? String
        self.uid = dictionary["uid"] as? String ?? ""

        }
    }

