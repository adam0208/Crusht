////
////  FbConnectCell.swift
////  Crusht
////
////  Created by Santiago Goycoechea on 10/21/19.
////  Copyright © 2019 William Kelly. All rights reserved.
////
//
//import UIKit
//
//class FbConnectCell: UITableViewCell {
//
//    override var frame: CGRect {
//        get {
//            return super.frame
//        }
//        set (newFrame) {
//            var frame = newFrame
//            frame.origin.x += 40
//            frame.size.width -= 2 * 40
//            super.frame = frame
//        }
//    }
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        self.addSubview(FBLoginBttn)
//        FBLoginBttn.fillSuperview()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    let FBLoginBttn: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Privacy Policy", for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
//        button.backgroundColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
//        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        button.layer.cornerRadius = 22
//        button.titleLabel?.adjustsFontForContentSizeCategory = true
//        return button
//    }()
//}
