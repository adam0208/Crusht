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
    
    var gender = String()
    var sexYouLike = String()
    var fullName: String? {
        didSet {
            checkFormValidity()
        }
    }
    var email: String? { didSet { checkFormValidity() } }
    var password: String? { didSet { checkFormValidity() } }
    
    var school: String?
    
    var age: Int?
    
    var bio: String? { didSet {checkFormValidity() }}
    
    var phone: String!
    
    var fbid: String?
    
    var birthday: String?
    //{ didSet {checkFormValidity() }}
    
    
    
    func performRegistration(completion: @escaping (Error?) -> ()) {
        
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
            ref.downloadURL(completion: { (url, err) in
                if let err = err {
                    completion(err)
                    return
                }
                self.bindableIsRegistering.value = false
                
                let imageUrl = url?.absoluteString ?? ""
               
                self.saveInfoToFirestore(imageUrl: imageUrl, completion: completion)
            })
        })
    }
    
    let token = Messaging.messaging().fcmToken
    
    fileprivate func saveInfoToFirestore(imageUrl: String, completion: @escaping (Error?) ->()) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData: [String: Any] =
            [
            
             "ImageUrl1": imageUrl,
            
        ]
        //let userAge = ["Age": age]
        Firestore.firestore().collection("users").document(uid).setData(docData, merge: true) { (err) in
            self.bindableIsRegistering.value = false
            if let err = err {
                completion(err)
                return
            }
            completion(nil)
        }
    }
    
    func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && bio?.isEmpty == false && bindableImage.value != nil
        bindableIsFormValid.value = isFormValid
        
    }
    

    
}
