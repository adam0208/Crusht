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
        button.backgroundColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100) .isActive = true
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.layer.cornerRadius = 16
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(logOutBttn)
        logOutBttn.fillSuperview()        //logOutBttn.center = CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0)
     

    }
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            frame.origin.x += 40
            frame.size.width -= 2 * 40
            super.frame = frame
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class FbConnectCell: UITableViewCell {

let FBLoginBttn: UIButton = {
    
    let button = UIButton(type: .system)
    button.setTitle("Privacy Policy", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
    button.backgroundColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
    button.heightAnchor.constraint(equalToConstant: 60).isActive = true
    button.widthAnchor.constraint(equalToConstant: 100)
    button.layer.cornerRadius = 22
    button.titleLabel?.adjustsFontForContentSizeCategory = true

    //button.addTarget(self, action: #selector(loginButtonClicked), for: .touchUpInside)
    return button
}()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(FBLoginBttn)
        FBLoginBttn.fillSuperview()
        //logOutBttn.center = CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0)
        //self.init(frame: )
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            frame.origin.x += 40
            frame.size.width -= 2 * 40
            super.frame = frame
        }
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ContactsTextCell: UITableViewCell {
    
    let privacyText: UILabel = {
        let label = UILabel()
        
        label.text = "If one of your contacts doesn't have Crusht and you heart them, an anonymous message will be sent to their device informing them that \"someone\" has a crush on them."
        label.font = UIFont.systemFont(ofSize: 15, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        
        label.textColor = .black
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
            addSubview(privacyText)
        
       
        privacyText.fillSuperview()
        //logOutBttn.center = CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0)
        //self.init(frame: )
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            frame.origin.x += 10
            frame.size.width -= 2 * 12
            super.frame = frame
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SupportCell: UITableViewCell {
    
    let email: UILabel = {
        let label = UILabel()
        
        label.text = "Support Email: info@crusht.co"
        label.font = UIFont.systemFont(ofSize: 15, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        
        label.textColor = .black
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(email)
        
        
        email.fillSuperview()
        //logOutBttn.center = CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0)
        //self.init(frame: )
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            frame.origin.x += 10
            frame.size.width -= 2 * 12
            super.frame = frame
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class VersionNumber: UITableViewCell {
    
    let version: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 15, weight: .heavy)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        
        label.textColor = .black
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
        
        //Then just cast the object as a String, but be careful, you may want to double check for nil
        if nsObject == nil {
            version.text = "Crusht LLC"
        }
        else {
            let v = nsObject as! String
        
            version.text = "Crusht Version \(v)"
        }
        addSubview(version)
        
        
        version.fillSuperview()
        //logOutBttn.center = CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0)
        //self.init(frame: )
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            frame.origin.x += 10
            frame.size.width -= 2 * 12
            super.frame = frame
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
