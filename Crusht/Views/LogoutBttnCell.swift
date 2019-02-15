//
//  LogoutBttnCell.swift
//  Crusht
//
//  Created by William Kelly on 2/9/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit

class LogoutBttnCell: UITableViewCell {
    
    let logOutBttn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100) .isActive = true
        button.layer.cornerRadius = 16
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(logOutBttn)
        logOutBttn.fillSuperview()        //logOutBttn.center = CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0)
     

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class FbConnectCell: UITableViewCell {

let FBLoginBttn: UIButton = {
    
    let button = UIButton(type: .system)
    button.setTitle("Connect Facebook", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
    button.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
    button.heightAnchor.constraint(equalToConstant: 60).isActive = true
    button.widthAnchor.constraint(equalToConstant: 100)
    button.layer.cornerRadius = 22
    //button.addTarget(self, action: #selector(loginButtonClicked), for: .touchUpInside)
    return button
}()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(FBLoginBttn)
        self.heightAnchor.constraint(equalToConstant: 200)
        FBLoginBttn.fillSuperview()
        //logOutBttn.center = CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0)
        //self.init(frame: )
    }
    


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
