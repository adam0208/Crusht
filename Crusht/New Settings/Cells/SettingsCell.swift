//
//  SettingsCell.swift
//  SettingsTemplate
//
//  Created by Stephen Dowless on 2/10/19.
//  Copyright © 2019 Stephan Dowless. All rights reserved.
//

import UIKit

protocol SectionType: CustomStringConvertible {
    var containSwitch: Bool {get}
    
}

enum SettingsSection: Int, CaseIterable, CustomStringConvertible {
    case Social
    case Communications
    case About
    
    var description: String {
        switch self {
        case .Social:
            return "Social"
        case .Communications: return "Communications"
        case .About:
            return "About"
        }
    }
}

enum SocialOptions: Int, CaseIterable, SectionType {
    var containSwitch: Bool {
        return false
    }
    
    case editProfile
    case logout
    var description: String {
    switch self {
    case .editProfile:
        return "Edit Profile"
    case .logout: return "Logout"
        }
    }
}

enum CommunicationOptions: Int, CaseIterable, SectionType {
    var containSwitch: Bool {
        switch self {
        case .notifications:
            return true
        case .location:
            return true
        }
    
        
    }
    
    case notifications
    case location
  
    var description: String {
    switch self {
    case .notifications:
        return "Notifications"
    case .location: return "Location"
   
        }
    }
}

enum AboutOptions: Int, CaseIterable, SectionType {

    var containSwitch: Bool {
       switch self {
            case .companyInfo:
             return false
       case .versionType:
            return false
       case .privacy:
        return false
       case .terms:
        return false
        }
    }
    
    case privacy
    case terms
    case companyInfo
    case versionType
    
    
    var description: String{
    
    switch self {
        
    case .privacy:
        return "Privacy"
    case .terms:
        return "Terms of Use"
    
    case .companyInfo:
        return "Copyright © 2020 Crusht LLC"
    case .versionType:
        return "Crusht \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject? ?? "" as AnyObject)"
        }
    
        }
    }

class SettingsCell: UITableViewCell {
    
    // MARK: - Properties
    
    var sectionType: SectionType? {
        didSet {
            guard let sectionType = sectionType else {return}
            textLabel?.text = sectionType.description
            switchControl.isHidden = !sectionType.containSwitch
            nextImageView.isHidden = sectionType.containSwitch
        }
    }
    
    lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = true
        switchControl.onTintColor = #colorLiteral(red: 1, green: 0, blue: 0.6713966727, alpha: 1)
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        //switchControl.addTarget(self, action: #selector(handleSwitchAction), for: .valueChanged)
        return switchControl
    }()
    
    lazy var nextImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = #imageLiteral(resourceName: "icons8-chevron-right-30.png")
        return iv
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(switchControl)
        switchControl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        switchControl.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        
        addSubview(nextImageView)
        nextImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        nextImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Selectors
    

    
}
