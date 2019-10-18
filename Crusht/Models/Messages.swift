//
//  Messages.swift
//  Crusht
//
//  Created by William Kelly on 12/15/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var fromId: String?
    var fromName: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    var toName: String?
    var videoUrl: String?
    var imageUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    
    //maybe get rid of toName
    
    init(dictionary: [String: Any]) {
        self.fromId = dictionary["fromId"] as? String
        self.text = dictionary["text"] as? String
        self.toId = dictionary["toId"] as? String
        self.toName = dictionary["toName"] as? String
        self.fromName = dictionary["fromName"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
        self.imageUrl = dictionary["imageUrl"] as? String
        self.imageWidth = dictionary["imageWidth"] as? NSNumber
        self.imageHeight = dictionary["imageHeight"] as? NSNumber
        self.videoUrl = dictionary["videoUrl"] as? String

    }
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
}

class CrushScore: NSObject {
    var crushScore: Int?
    init(dictionary: [String: Any]) {
        self.crushScore = dictionary["CrushScore"] as? Int
    }
    
    var toString: String {
        let crushScore = self.crushScore ?? 0
        if crushScore > -1 && crushScore <= 50 {
            return "Crusht Score: 😊😎"
        }
        else if crushScore > 50 && crushScore <= 100 {
            return "Crusht Score: 😊😎😍"
        }
        else if crushScore > 100 && crushScore <= 200 {
            return "Crusht Score: 😊😎😍🔥"
        }
        else if crushScore > 200 && crushScore <= 400 {
            return "Crusht Score: 😊😎😍🔥❤️"
        }
        else if crushScore > 400 {
            return " Crusht Score: 😊😎😍🔥❤️👀"
        }
        else {
            return ""
        }
    }
    
}

