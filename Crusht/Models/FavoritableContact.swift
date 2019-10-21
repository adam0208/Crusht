//
//  FavoritableContact.swift
//  Crusht
//
//  Created by Santiago Goycoechea on 10/21/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import Foundation
import Contacts

struct FavoritableContact {
    let contact: CNContact
    var hasFavorited: Bool
    
    var name: String {
        return contact.givenName + " " + contact.familyName
    }
    
    var phoneCell: String {
        let phoneString = contact.phoneNumbers.first?.value.stringValue ?? ""
        let phoneIDStripped = phoneString.replacingOccurrences(of: " ", with: "")
        let phoneNoParen = phoneIDStripped.replacingOccurrences(of: "(", with: "")
        let phoneNoParen2 = phoneNoParen.replacingOccurrences(of: ")", with: "")
        let phoneNoDash = phoneNoParen2.replacingOccurrences(of: "-", with: "")
        return phoneNoDash.count < 11 ? "+1\(phoneNoDash)" : phoneNoDash
    }
}
