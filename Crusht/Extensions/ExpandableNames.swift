//
//  ExpandableNames.swift
//  Crusht
//
//  Created by William Kelly on 12/11/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import Foundation
import Contacts

struct ExpandableNames {
    var isExpanded: Bool
    var names: [FavoritableContact]
}

struct FavoritableContact {
    let contact: CNContact
    var hasFavorited: Bool
}
