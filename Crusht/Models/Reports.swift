//
//  File.swift
//  Crusht
//
//  Created by William Kelly on 3/29/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import Foundation

class Reports: NSObject {
    var reportNumber: Int?
    var uid: String?
    var offenderName: String?
    var offenderEmail: String?
    var offenderUID: String?
    var text: String?
    
    init(dictionary: [String: Any]) {
        self.reportNumber = dictionary["number-of-reports"] as? Int
        self.uid = dictionary["uid"] as? String ?? ""
        self.offenderName = dictionary["offender-name"] as? String ?? ""
        self.offenderEmail = dictionary["email"] as? String ?? ""
        self.text = dictionary["text"] as? String ?? ""
        self.offenderUID = dictionary["reporter-uid"] as? String ?? ""
    }
}
