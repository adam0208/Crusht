//
//  VenueCell.swift
//  Crusht
//
//  Created by William Kelly on 4/20/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase
//import Nuke
import SDWebImage

class VenueCell: UITableViewCell {
    
    var place: Place?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }

    func setup(place: Place) {
        textLabel?.text = place.name
        guard let imageUrl = place.photos.first?.photoReference else {return}
        // This is needed to avoid showing the wrong image while the actual one is being downloaded.
        // The problem is caused by cell reuse.
        self.profileImageView.image = nil
        
        let photoUrl = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(imageUrl)&key=AIzaSyAckZAj7XWUiaXNDxGw-k8A2wrrMp7El2g"
        
        print(photoUrl, "Not good")
        
        let url = URL(string: photoUrl )
        //Nuke.loadImage(with: url!, into: self.profileImageView)
        SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
            self.profileImageView.image = image
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
}
