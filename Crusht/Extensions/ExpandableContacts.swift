//
//  ExpandableContacts.swift
//  Crusht
//
//  Created by William Kelly on 12/11/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import Foundation
import Contacts

struct ExpandableContacts {
    var isExpanded: Bool
    var contacts: [FavoritableContact]
    
    func filterBy(text: String) -> ExpandableContacts {
        var filteredContacts = [FavoritableContact]()
        for contact in contacts where contact.name.lowercased().contains(text.lowercased()) {
            filteredContacts.append(contact)
        }
        return ExpandableContacts(isExpanded: isExpanded, contacts: filteredContacts)
    }
}

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
