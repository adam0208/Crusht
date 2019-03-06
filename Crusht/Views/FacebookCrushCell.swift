//
//  FacebookCrushCell.swift
//  Crusht
//
//  Created by William Kelly on 2/14/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore

class FacebookCrushCell: UITableViewCell {
    var crush: User? {
        didSet {
            setupNameAndProfileImageFB()
            
            //detailTextLabel?.text = crush?.name
        }
    }

    var fblink: FacebookCrushController?
    
    fileprivate var user: User?
    
    var hasFavoried = Bool()
    
    let starButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(#imageLiteral(resourceName: "heartIcon3Crusht.png"), for: .normal)
    button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)

    button.tintColor = .red
        return button
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryView = starButton
        
        addSubview(starButton)
        addSubview(profileImageView)
        
        starButton.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        starButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        starButton.widthAnchor.constraint(equalToConstant: 48).isActive = true
        starButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
      
        starButton.addTarget(self, action: #selector(handleTappedFB), for: .touchUpInside)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
    }
    
    
    fileprivate func setupNameAndProfileImageFB() {
        print("starting fb")
        let req = GraphRequest(graphPath: "me/friends", parameters: ["fields": "email,first_name,last_name,gender,picture"], accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!)
        req.start({ (connection, result) in
            switch result {
            case .failed(let error):
                print(error)
                print("no fb for you")
            case .success(let graphResponse):
                print("Success doing this fb shit")
                if let responseDictionary = graphResponse.dictionaryValue {
                    print(responseDictionary)
                    //let photoData = pictureUrlFB!["data"] as? [String:Any]
                    //let photoUrl = photoData!["url"] as? String
                    
                    let responseDictionaryFriends = graphResponse.dictionaryValue
                    let data: NSArray = responseDictionaryFriends!["data"] as! NSArray
                    
                    //print("jajajajajjajajajajja", data)
                    
                    for i in  0..<data.count {
                        let dict = data[i] as! NSDictionary
                        let temp = dict.value(forKey: "id") as! String
                        Firestore.firestore().collection("users").whereField("fbid", isEqualTo: temp).getDocuments(completion: { (snapshot, err) in
                            if let err = err {
                                print("failed getting fb friends", err)
                            }
                            snapshot?.documents.forEach({ (documentSnapshot) in
                                if let dictionary = documentSnapshot.data() as [String: AnyObject]? {
                                    
                                    self.textLabel?.text = dictionary["Full Name"] as? String
                                    self.detailTextLabel?.text = dictionary["School"] as? String
                                    
                                    if let profileImageUrl = dictionary["ImageUrl1"] as? String {
                                        self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
                                    }
                                    
                                }
                                
                            })
                            
                        })
                    }
                    
                    
                }
            }
            
            
        })
    }
 
    
//    fileprivate func setupNameAndProfileImage() {
//           let school = user?.school ?? "I suck a lot"
//        //if let uid = ?.chatPartnerId() {
//            Firestore.firestore().collection("users").whereField("School", isEqualTo: school).getDocuments { (snapshot, err) in
//
//                if let err = err {
//                    print("FAILLLLLLLLL", err)
//                }
//
//                snapshot?.documents.forEach({ (documentSnapshot) in
//                    if let dictionary = documentSnapshot.data() as [String: AnyObject]? {
//
//                            self.textLabel?.text = dictionary["Full Name"] as? String
//                            self.detailTextLabel?.text = dictionary["School"] as? String
//
//                            if let profileImageUrl = dictionary["ImageUrl1"] as? String {
//                                self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
//                            }
//
//                        }
//
//                    })
//
//            }
//
//        }
    
    
    @objc func handleTappedFB() {
        fblink?.hasTappedFBCrush(cell: self)
        print("finished")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
