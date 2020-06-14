//
//  NiceEditProfileCell.swift
//  Crusht
//
//  Created by William Kelly on 6/12/20.
//  Copyright © 2020 William Kelly. All rights reserved.
//

import UIKit

protocol SectionType2: CustomStringConvertible {
    var containArrow: Bool {get}
    
}

enum EditSection: Int, CaseIterable, CustomStringConvertible {
    case Profile
    case Location
    case VenueLocation
    
    var description: String {
        switch self {
        case .Profile:
            return "Edit Profile Info"
        case .Location: return "Location Based Match Settings"
        case .VenueLocation:
            return "Venue Settings"
        }
    }
}

enum ProfileOptions: Int, CaseIterable, SectionType2 {
        
    var containArrow: Bool {
        switch self {
        case .name:
            return true
        case .school:
            return true
        case .occupation:
            return true
        case .age:
            return false
        case .bio:
            return true
        case .yourGender:
            return true
        case .genderPreference:
            return true
        }
    }
    case name
    case school
    case occupation
    case age
    case bio
    case yourGender
    case genderPreference
    
    var description: String {
    var user: User?
    switch self {
    case .name:
        return user?.name ?? "Edit"
    case .school:
        return user?.school ?? "Edit"
    case .occupation:
        return user?.occupation ?? "Edit"
    case .age:
        return "\(user?.age ?? 18)"
    case .bio:
        return user?.bio ?? "Edit"
    case .yourGender:
        return user?.gender ?? "Edit"
    case .genderPreference:
        return user?.sexPref ?? "Edit"
        
        }
    }
}

enum LocationMatchingOptions: Int, CaseIterable, SectionType2 {
    
    var containArrow: Bool {
        
        switch self {
         case .minAge:
             return false
         case .maxAge:
             return false
        case .maxDistance:
            return false
         }
        
     }
     

    case minAge
    case maxAge
    case maxDistance
    
    var description: String {
        var user: User?
        switch self {
        case .minAge:
            return "\(user?.minSeekingAge ?? 18)"
        case .maxAge:
            return "\(user?.maxSeekingAge ?? 50)"
        case .maxDistance:
            return "\(user?.maxDistance ?? 10)"
        }
    }
    
}

enum VenueOptions: Int, CaseIterable, SectionType2 {
    
    var containArrow: Bool {
        switch self {
        case .maxDistance:
            return false
        case .currentVenue:
            return false
        }
    }
    
    
    case maxDistance
    case currentVenue
    
    var description: String {
        var user: User?

        switch self {
        case .currentVenue:
            return user?.currentVenue ?? "Edit"
        case .maxDistance:
            return "\(user?.maxVenueDistance ?? 4)"
            
        }
    }
}
    

class NiceEditProfileCell: UITableViewCell {
    
    var sectionType: SectionType2? {
        didSet {
            guard let sectionType = sectionType else {return}
            userText.text = sectionType.description
            nextImageView.isHidden = !sectionType.containArrow
        }
    }
    
    var titleText: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    var userText: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        return label
    }()
    
    
    
    lazy var nextImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = #imageLiteral(resourceName: "icons8-chevron-right-30.png")
        return iv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        addSubview(titleText)
//        titleText.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 6).isActive = true
//        titleText.leftAnchor.constraint(equalTo: leftAnchor, constant: -12).isActive = true
//
//        addSubview(userText)
//        userText.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -6).isActive = true
//        userText.leftAnchor.constraint(equalTo: leftAnchor, constant: -12).isActive = true
//
        
        let stack = UIStackView(arrangedSubviews: [titleText, userText])
        stack.axis = .vertical
        stack.spacing = 1
        stack.distribution = .fill
        
        addSubview(stack)
        
        stack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil, padding: .init(top: 6, left: 8, bottom: 6, right: 0))
        
        addSubview(nextImageView)
        nextImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        nextImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
