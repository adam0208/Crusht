//
//  CrushScore.swift
//  Crusht
//
//  Created by Santiago Goycoechea on 10/21/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import Foundation

class CrushScore {
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
