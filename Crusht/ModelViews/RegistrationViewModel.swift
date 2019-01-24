//
//  RegistrationViewModel.swift
//  Crusht
//
//  Created by William Kelly on 12/6/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import Firebase

class RegistrationViewModel {

var bindableIsRegistering = Bindable<Bool>()
var bindableImage = Bindable<UIImage>()
var bindableIsFormValid = Bindable<Bool>()


var fullName: String? {
    didSet {
        checkFormValidity()
    }
}
var email: String? { didSet { checkFormValidity() } }
var password: String? { didSet { checkFormValidity() } }
    
var school: String? { didSet { checkFormValidity() } }
    
    var age: Int? { didSet {checkFormValidity() }}
    
    var bio: String? { didSet {checkFormValidity() }}
    
    var phone: String!
   

    func performRegistration(completion: @escaping (Error?) -> ()) {
        
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//
//        bindableIsRegistering.value = true
//
//
//
//        let docData: [String: Any] =
//            ["Full Name": "",
//             "uid": uid,
//
//             "School": school ?? "",
//             "Age": age,
//             "Bio": ,
//             "minSeekingAge": 18,
//             "maxSeekingAge": 50,
//             "ImageUrl1":
//        ]
//
//        Firestore.firestore().collection("users").document(uid).setData(docData)
//
//            print("Successfully registered user:", res?.user.uid ?? "")
        
            self.saveImageToFirebase(completion: completion)
            
        
    }
    
    
    fileprivate func saveImageToFirebase(completion: @escaping (Error?) ->()) {
        
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
        ref.putData(imageData, metadata: nil, completion: {(_, err) in
            if let err = err {
                completion(err)
                return //bail
            }
            print("finished Uploading image")
            ref.downloadURL(completion: { (url, err) in
                if let err = err {
                    completion(err)
                    return
                }
                self.bindableIsRegistering.value = false
                print("Download url of our image is:", url?.absoluteString ?? "")
                
                let imageUrl = url?.absoluteString ?? ""
                self.saveInfoToFirestore(imageUrl: imageUrl, completion: completion)
            })
        })
    }


    fileprivate func saveInfoToFirestore(imageUrl: String, completion: @escaping (Error?) ->()) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData: [String: Any] =
            ["Full Name": fullName ?? "",
             "uid": uid,
             "Bio": bio ?? "",
             "School": school ?? "",
            "Age": age ?? 18,
            "minSeekingAge": 18,
                "maxSeekingAge": 50,
                "PhoneNumber": phone,
            "ImageUrl1": imageUrl]
        //let userAge = ["Age": age]
        Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
            self.bindableIsRegistering.value = false
            if let err = err {
                completion(err)
                return
            }
            completion(nil)
        }
    }
    
     func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && bio?.isEmpty == false && school?.isEmpty == false && "\(age ?? -1)".isEmpty == false && bindableImage.value != nil
        bindableIsFormValid.value = isFormValid
    
    }

}
