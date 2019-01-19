//
//  SeniorFiveModel.swift
//  Crusht
//
//  Created by William Kelly on 1/11/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit

class Crushes: NSObject {
    var crush1: String?
    var crush2: String?
    var crush3: String?
    var crush4: String?
    var crush5: String?
    var comments: String?
    var uid: String?
    var school: String?
    var name: String?
    var timestamp: NSNumber?
    

init(dictionary: [String: Any]) {

    self.crush1 = dictionary["Crush1"] as? String ?? ""
    self.crush2 = dictionary["Crush2"] as? String ?? ""
    self.crush3 = dictionary["Crush3"] as? String ?? ""
    self.crush4 = dictionary["Crush4"] as? String ?? ""
    self.crush5 = dictionary["Crush5"] as? String ?? ""
    self.comments = dictionary["Comments"] as? String ?? ""
    self.uid = dictionary["uid"] as? String ?? ""
    self.name = dictionary["Name of Poster"] as? String ?? ""
    self.school = dictionary["School"] as? String ?? ""
    self.timestamp = dictionary["timestamp"] as? NSNumber

    
    }
}
