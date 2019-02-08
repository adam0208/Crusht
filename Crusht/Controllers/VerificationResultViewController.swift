//
//  VerificationResultViewController.swift
//  Crusht
//
//  Created by William Kelly on 1/31/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

//import UIKit
//
//class VerificationResultViewController: UIViewController {
//    
//    
//    let successIndication: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
//        label.textAlignment = .center
//        label.numberOfLines = 0
//        return label
//    }()
//    
//    var message: String?
//    
//    override func viewDidLoad() {
//        if let resultToDisplay = message {
//            successIndication.text = resultToDisplay
//        } else {
//            successIndication.text = "Something went wrong!"
//        }
//        
//        super.viewDidLoad()
//        view.addSubview(successIndication)
//        successIndication.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor)
//    }
//}
