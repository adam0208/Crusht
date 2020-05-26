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
    let token = Messaging.messaging().fcmToken
    
    var bindableIsRegistering = Bindable<Bool>()
    var bindableImage = Bindable<UIImage>()
    var bindableIsFormValid = Bindable<Bool>()
    
    var gender = String()
    var sexYouLike = String()
    var password: String? { didSet { checkFormValidity() } }
    var school: String?
    var age: Int?
    var bio: String? { didSet {checkFormValidity() }}
    var phone: String!
    var birthday: String?
    
    var fullName: String? {
        didSet {
            checkFormValidity()
        }
    }
    
    private func performRegistration(completion: @escaping (Error?) -> ()) {
        self.saveImageToFirebase(completion: completion)
    }
    
    private func saveImageToFirebase(completion: @escaping (Error?) ->()) {
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
        ref.putData(imageData, metadata: nil) { (_, err) in
            if let err = err {
                completion(err)
                return
            }
            ref.downloadURL { (url, err) in
                if let err = err {
                    completion(err)
                    return
                }
                self.bindableIsRegistering.value = false
                let imageUrl = url?.absoluteString ?? ""
                self.saveInfoToFirestore(imageUrl: imageUrl, completion: completion)
            }
        }
    }
    
    private func saveInfoToFirestore(imageUrl: String, completion: @escaping (Error?) ->()) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData: [String: Any] = ["ImageUrl1": imageUrl]
        Firestore.firestore().collection("users").document(uid).setData(docData, merge: true) { err in
            self.bindableIsRegistering.value = false
            completion(err)
        }
    }
    
    private func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false && bio?.isEmpty == false && bindableImage.value != nil
        bindableIsFormValid.value = isFormValid
    }
}
