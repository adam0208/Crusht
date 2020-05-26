//
//  Post.swift
//  Crusht
//
//  Created by William Kelly on 2/20/20.
//  Copyright © 2020 William Kelly. All rights reserved.
//

import Foundation

class Post: NSObject {
    var postID: String?
    var postOwnerUID: String?
    var postOwnerName: String?
    var postLikes: Int?
    var postNumberOfComments: Int?
    var postImageUrl: String?
    var postText: String?
    var postOwnerProfileImageURL: String?
    var timestamp: NSNumber?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    
    init(dictionary: [String: Any]) {
        self.postID = dictionary["postID"] as? String ?? ""
        self.postOwnerUID = dictionary["postOwnerUID"] as? String ?? ""
        self.postOwnerName = dictionary["postOwnerName"] as? String ?? ""
        self.postLikes = dictionary["postLikes"] as? Int
        self.postNumberOfComments = dictionary["postNumberOfComments"] as? Int
        self.postImageUrl = dictionary["postImageUrl"] as? String? ?? ""
        self.postText = dictionary["postText"] as? String ?? ""
        self.postOwnerProfileImageURL = dictionary["postOwnerProfileImageURL"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? NSNumber
        self.imageWidth = dictionary["imageWidth"] as? NSNumber
        self.imageHeight = dictionary["imageHeight"] as? NSNumber
        
    }
}
