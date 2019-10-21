//
//  ExpandableContacts.swift
//  Crusht
//
//  Created by William Kelly on 12/11/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import Foundation

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
