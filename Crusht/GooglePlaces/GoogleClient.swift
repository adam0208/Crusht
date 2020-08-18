//
//  GoogleClient.swift
//  Crusht
//
//  Created by William Kelly on 6/8/20.
//  Copyright © 2020 William Kelly. All rights reserved.
//


import Foundation

import CoreLocation

protocol GoogleClientRequest {

    var googlePlacesKey : String { get set }
    func getGooglePlacesData(forKeyword keyword: String, location: CLLocation, withinMeters radius: Int, using completionHandler: @escaping (GooglePlacesResponse) -> ())
    
}

class GoogleClient : GoogleClientRequest {
     // implement the constants and methods contained in your protocol
    var googlePlacesKey: String = "AIzaSyAckZAj7XWUiaXNDxGw-k8A2wrrMp7El2g"
    
    let session = URLSession(configuration: .default)

      
       func getGooglePlacesData(forKeyword keyword: String, location: CLLocation,withinMeters radius: Int, using completionHandler: @escaping (GooglePlacesResponse) -> ())  {
        
            let url = googlePlacesDataURL(forKey: googlePlacesKey, location: location, keyword: keyword)
            //b
            let task = session.dataTask(with: url) { (responseData, _, error) in
            //c
            if let error = error {
                print(error.localizedDescription)
                return
             }
            //d
            guard let data = responseData, let response = try? JSONDecoder().decode(GooglePlacesResponse.self, from: data) else {
                  //e
                  completionHandler(GooglePlacesResponse(results:[]))
                       return
                  }
                  //f
                  completionHandler(response)
             }
             //g
             task.resume()
    }
    
    func googlePlacesDataURL(forKey apiKey: String, location: CLLocation, keyword: String) -> URL {
        
        let baseURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        let locationString = "location=" + String(location.coordinate.latitude) + "," + String(location.coordinate.longitude)
        let rankby = "rankby=distance"
        let keywrd = "type=" + keyword
        let key = "key=" + apiKey
        
        return URL(string: baseURL + locationString + "&" + rankby + "&" + keywrd + "&" + key)!
    }
    
    
}
