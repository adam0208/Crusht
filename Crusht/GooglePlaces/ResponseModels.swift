//
//  ResponseModels.swift
//  Crusht
//
//  Created by William Kelly on 6/8/20.
//  Copyright © 2020 William Kelly. All rights reserved.
//

import Foundation

struct GooglePlacesResponse : Codable {
    let results : [Place]
    enum CodingKeys : String, CodingKey {
        case results = "results"
    }
}

struct Place: Codable {
    
    let geometry : Location
    let name : String
    let openingHours : OpenNow?
    let photos : [PhotoInfo]
    let types : [String]
    let address : String
    let id : String
    
    enum CodingKeys : String, CodingKey {
        case geometry = "geometry"
        case name = "name"
        case openingHours = "opening_hours"
        case photos = "photos"
        case types = "types"
        case address = "vicinity"
        case id = "id"
       // case tempCloased = "business_status"
    }
}
    struct Location : Codable {
        
        let location : LatLong
        
        enum CodingKeys : String, CodingKey {
            case location = "location"
        }
        
        struct LatLong : Codable {
            
            let latitude : Double
            let longitude : Double
            
            enum CodingKeys : String, CodingKey {
                case latitude = "lat"
                case longitude = "lng"
            }
        }
    }
    
    struct OpenNow : Codable {
        
        let isOpen : Bool
        
        enum CodingKeys : String, CodingKey {
            case isOpen = "open_now"
        }
    }
    
//    struct TempClosed : Codable {
//
//        let isClosed : Bool
//
//        enum CodingKeys : String, CodingKey {
//            case isClosed = "CLOSED_TEMPORARILY"
//            }
//        }

    
    struct PhotoInfo : Codable {
        //photoreference was string
        let height : Int
        let width : Int
        let photoReference : String
        
        enum CodingKeys : String, CodingKey {
            case height = "height"
            case width = "width"
            case photoReference = "photo_reference"
        }
    }

