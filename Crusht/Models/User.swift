//
//  User.swift
//  Crusht
//
//  Created by William Kelly on 12/5/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//
import UIKit
import Firebase

struct User: ProducesCardViewModel {
// defining our properties for our model layer
    var name: String?
    var age: Int?
    var school: String?
    var imageUrl1: String?
     var imageUrl2: String?
     var imageUrl3: String?
    var uid: String?
    var bio: String?
    var phoneNumber: String?
    
    
    var minSeekingAge: Int?
    var maxSeekingAge: Int?

    
    var toId: String?
    var fromId: String?
    
    init(dictionary: [String: Any]) {
        //initialize our user stuff
       
        //let age = dictionary["Age"] as? Int
        self.name = dictionary["Full Name"] as? String ?? ""
        self.age = dictionary["Age"] as? Int
        self.school = dictionary["School"] as? String ?? ""
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
        
    
    }

func toCardViewModel() -> CardViewModel {
    let attributedText = NSMutableAttributedString(string: name ?? "", attributes: [.font: UIFont.systemFont(ofSize: 32, weight: .heavy)])
    
    let ageSting = age != nil ? "\(age!)" : "N/A"
    
    attributedText.append(NSAttributedString(string: "  \(ageSting)", attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .regular)]))
    
    let schoolString = school != nil ? school! : "Not Available"
    
    attributedText.append(NSAttributedString(string: "\n\(schoolString)", attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .regular)]))
    
    print(imageUrl1 ?? "")
    
    var imageUrls = [String]()
    if let url = imageUrl1 { imageUrls.append(url) }
    if let url = imageUrl2 { imageUrls.append(url) }
    if let url = imageUrl3 { imageUrls.append(url) }
    
    return CardViewModel(uid: self.uid ?? "", imageNames: imageUrls, attributedString: attributedText, textAlignment: .left)
    
    }
    
    func crushPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
}
