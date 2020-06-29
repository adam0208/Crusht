//
//  Party.swift
//  Crusht
//
//  Created by William Kelly on 2/17/20.
//  Copyright © 2020 William Kelly. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Party: NSObject {
    var partyName: String?
    var partyLocation: String?
    var partyPhotoUrl: String?
    var hostUID: String?
    var partyDetails: String?
    var startTime: NSNumber?
    var endTime: NSNumber?
    var guestPhoneNumbers: [String?]
    var partyUID: String?
    
    init(dictionary: [String: Any]) {
        self.partyName = dictionary["partyName"] as? String ?? ""
        self.partyLocation = dictionary["partyLocation"] as? String ?? ""
        self.partyPhotoUrl = dictionary["partyPhotoUrl"] as? String ?? ""
        self.hostUID = dictionary["hostUID"] as? String ?? ""
        self.partyDetails = dictionary["partyDetails"] as? String ?? ""
        self.startTime = dictionary["startTime"] as? NSNumber
        self.endTime = dictionary["endTime"] as? NSNumber
        self.guestPhoneNumbers = dictionary["guests"] as? [String?] ?? [""]
        self.partyUID = dictionary["partyUID"] as? String ?? ""
    }
}

class Guest: NSObject {
    var phoneNumber: String?
    var isAdmin: Bool?
    var going: Bool?
    var uid: String?
    
    var firstName: String?
    var lastName: String?
    
    var imageUrl1: String?

    
    
    init(dictionary: [String: Any]) {
        self.phoneNumber = dictionary["PhoneNumber"] as? String ?? ""
        self.firstName = dictionary["First Name"] as? String ?? ""
        self.lastName = dictionary["Last Name"] as? String ?? ""
        self.imageUrl1 = dictionary["ImageUrl1"] as? String
        self.uid = dictionary["uid"] as? String ?? ""
        self.isAdmin = dictionary["isAdmin"] as? Bool
        self.going = dictionary["going"] as? Bool

    }
}
