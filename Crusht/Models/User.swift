//
//  User.swift
//  Crusht
//
//  Created by William Kelly on 12/5/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//
import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct User: ProducesCardViewModel {
    var name: String?
    var firstName: String?
    var lastName: String?
    var age: Int?
    var school: String?
    var occupation: String?
    
    var imageUrl1: String?
    var imageUrl2: String?
    var imageUrl3: String?
    
    var uid: String?
    var bio: String?
    var phoneNumber: String?
    var currentVenue: String?
    var crushScore: Int?
    var g: String?
    
    var minSeekingAge: Int?
    var maxSeekingAge: Int?
    var maxDistance: Int?
    
    var maxVenueDistance: Int?

    
    var toId: String?
    var fromId: String?
    var fbid: String?
    
    var lat: String?
    var long: String?
    var deviceID: String?
    var email: String?
    
    var verified: String? //Make Boolean
    
    var birthday: String?
    
    var sexPref: String?
    
    var gender: String?
    
    var timeLastJoined: NSNumber?
    
    init(dictionary: [String: Any]) {
        self.age = dictionary["Age"] as? Int
        self.name = dictionary["Full Name"] as? String ?? ""
        self.firstName = dictionary["First Name"] as? String ?? ""
        self.lastName = dictionary["Last Name"] as? String ?? ""
        self.birthday = dictionary["Birthday"] as? String ?? ""
        self.school = dictionary["School"] as? String ?? ""
        self.occupation = dictionary["Occupation"] as? String ?? ""
        self.imageUrl1 = dictionary["ImageUrl1"] as? String
        self.imageUrl2 = dictionary["ImageUrl2"] as? String
        self.imageUrl3 = dictionary["ImageUrl3"] as? String
        self.uid = dictionary["uid"] as? String ?? ""
        self.bio = dictionary["Bio"] as? String ?? ""
        self.minSeekingAge = dictionary["minSeekingAge"] as? Int
        self.maxSeekingAge = dictionary["maxSeekingAge"] as? Int
        self.toId = dictionary["toCrush"] as? String ?? ""
        self.fromId = dictionary["fromCrush"] as? String ?? ""
        self.phoneNumber = dictionary["PhoneNumber"] as? String ?? ""
        self.crushScore = dictionary["CrushScore"] as? Int
        self.fbid = dictionary["fbid"] as? String ?? ""
        self.lat = dictionary["lat"] as? String ?? ""
        self.long = dictionary["long"] as? String ?? ""
        self.deviceID = dictionary["deviceID"] as? String ?? ""
        
        self.maxDistance = dictionary["maxDistance"] as? Int
        
        self.maxVenueDistance = dictionary["maxVenueDistance"] as? Int
        
        self.email = dictionary["email"] as? String ?? ""
        self.verified = dictionary["verified"] as? String ?? ""
        self.sexPref = dictionary["Gender-Preference"] as? String ?? ""
        self.gender = dictionary["User-Gender"] as? String ?? ""
        self.g = dictionary["g"] as? String ?? ""
        
        self.currentVenue = dictionary["CurrentVenue"] as? String ?? ""
        
        self.timeLastJoined = dictionary["TimeLastJoined"] as? NSNumber
    }

    func toCardViewModel() -> CardViewModel {
        let attributedText = NSMutableAttributedString(string: firstName ?? "", attributes: [.font: UIFont.systemFont(ofSize: 32, weight: .heavy)])
        
        let ageSting = age != nil ? "\(age!)" : "N/A"
        attributedText.append(NSAttributedString(string: "  \(ageSting)", attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .regular)]))
        
        let schoolString = school != nil ? school! : "Not Available"
        attributedText.append(NSAttributedString(string: "\n\(schoolString)", attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .regular)]))
        
        var imageUrls = [String]()
        if let url = imageUrl1 { imageUrls.append(url) }
        if let url = imageUrl2, url != "" { imageUrls.append(url) }
        if let url = imageUrl3, url != "" { imageUrls.append(url) }
        
        return CardViewModel(uid: self.uid ?? "", bio: self.bio ?? "", phone: self.phoneNumber ?? "", imageNames: imageUrls, attributedString: attributedText, textAlignment: .left)
    }
    
    func crushPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
    func calculateAge(birthday: String) -> Int {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM/dd/yyyy"
        let birthdayDate = dateFormater.date(from: birthday)
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
        let now = Date()
        let calcAge = (calendar.components(.year, from: birthdayDate ?? dateFormater.date(from: "10-31-1995")!, to: now, options: []))
        let age = calcAge.year
        return age!
    }
    
    func hasSamePreferences(user: User) -> Bool {
        return user.maxDistance == maxDistance && user.minSeekingAge == minSeekingAge
            && user.maxSeekingAge == maxSeekingAge && user.school == school && user.currentVenue == currentVenue
    }
}
