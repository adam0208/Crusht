//
//  PartyPageCell.swift
//  Crusht
//
//  Created by William Kelly on 2/20/20.
//  Copyright © 2020 William Kelly. All rights reserved.
//

import UIKit
import AVFoundation
import SDWebImage

class PartyPageCell: UICollectionViewCell {
    var party: Party?
    var post: Post?
    var partyPageController: PartyPageController?
    var postView = UIView()
    
    required init?(coder aDecoder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }
      
      override init(frame: CGRect) {
          super.init(frame: frame)
        backgroundColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
        postView.backgroundColor = .white
        addSubview(postView)
        postView.addSubview(nameLabel)
        postView.addSubview(profileImageView)
        postView.addSubview(statusTextView)
        postView.addSubview(statusImageView)
        postView.addSubview(likesLabel)
        postView.addSubview(dividerLineView)
        postView.addSubview(timeLabel)
        
        postView.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor, padding: .init(top: 0, left: 10, bottom: 0, right: 10))
        
        profileImageView.anchor(top: postView.topAnchor, leading: postView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 15, left: 10, bottom: 0, right: 0))
        nameLabel.anchor(top: profileImageView.topAnchor, leading: profileImageView.trailingAnchor, bottom: profileImageView.bottomAnchor, trailing: nil, padding: .init(top: 5, left: 8, bottom: 5, right: 0))
        timeLabel.anchor(top: profileImageView.topAnchor, leading: nil, bottom: profileImageView.bottomAnchor, trailing: postView.trailingAnchor, padding: .init(top: 5, left: 0, bottom: 5, right: 8))
        
      }
    
    func setupCell(post: Post) {
        
        guard let seconds = post.timestamp?.doubleValue else { return }
                      
                      let timestampDate = Date(timeIntervalSince1970: seconds)
                      let dateFormatter = DateFormatter()
                      dateFormatter.dateFormat = "h:mm a"
                      
                      let elapsedTimeInSeconds = NSDate().timeIntervalSince(timestampDate)
                      let secondInDays: TimeInterval = 60 * 60 * 24
              
                      if elapsedTimeInSeconds > 7 * secondInDays {
                          dateFormatter.dateFormat = "MM/dd/yy"
                      } else if elapsedTimeInSeconds > secondInDays {
                          dateFormatter.dateFormat = "EEE"
                      }
                      timeLabel.text = dateFormatter.string(from: timestampDate)
        
        let stack = UIStackView(arrangedSubviews: [likesLabel, UIView(), commentLabel])
        stack.axis = .horizontal
        stack.distribution = .equalCentering
        stack.backgroundColor = .white
        addSubview(stack)
        nameLabel.text = post.postOwnerName
            let imageUrl = post.postImageUrl!
              let url = URL(string: imageUrl)
           //   Nuke.loadImage(with: url!, into: self.profileImageView)
              SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                  self.statusImageView.image = image
              }
        let imageUrl2 = post.postOwnerProfileImageURL!
                    let url2 = URL(string: imageUrl2)
                 //   Nuke.loadImage(with: url!, into: self.profileImageView)
                    SDWebImageManager().loadImage(with: url2, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                        self.profileImageView.image = image
                    }
            statusTextView.text = post.postText
            likesLabel.text = "Like \(post.postLikes ?? 0)"
            commentLabel.text = "Comment \(post.postNumberOfComments ?? 0)"
       print(imageUrl, "llllllll")
        if imageUrl != "" {
            statusImageView.anchor(top: profileImageView.bottomAnchor, leading: postView.leadingAnchor, bottom: nil, trailing: postView.trailingAnchor, padding: .init(top: 10, left: 10, bottom: 10, right: 10))
            statusTextView.anchor(top: statusImageView.bottomAnchor, leading: postView.leadingAnchor, bottom: nil, trailing: postView.trailingAnchor, padding: .init(top: 10, left: 15, bottom: 3, right: 15))
            dividerLineView.anchor(top: statusTextView.bottomAnchor, leading: postView.leadingAnchor, bottom: nil, trailing: postView.trailingAnchor, padding: .init(top: 2, left: 0, bottom: 0, right: 0))
            stack.anchor(top: dividerLineView.bottomAnchor, leading: postView.leadingAnchor, bottom: postView.bottomAnchor, trailing: postView.trailingAnchor, padding: .init(top: 5, left: 15, bottom: 5, right: 15))
        }
        else {
            statusTextView.anchor(top: profileImageView.bottomAnchor, leading: postView.leadingAnchor, bottom: nil, trailing: self.trailingAnchor, padding: .init(top: 10, left: 10, bottom: 10, right: 10))
             dividerLineView.anchor(top: statusTextView.bottomAnchor, leading: postView.leadingAnchor, bottom: nil, trailing: postView.trailingAnchor, padding: .init(top: 2, left: 0, bottom: 0, right: 0))
            stack.anchor(top: dividerLineView.bottomAnchor, leading: postView.leadingAnchor, bottom: postView.bottomAnchor, trailing: postView.trailingAnchor, padding: .init(top: 5, left: 15, bottom: 5, right: 15))
       }
        
    }
    
          let nameLabel: UILabel = {
               let label = UILabel()
               label.numberOfLines = 2
               return label
           }()
           
           let profileImageView: UIImageView = {
               let imageView = UIImageView()
               imageView.contentMode = .scaleAspectFill
                imageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
                imageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
                imageView.layer.cornerRadius = 24
                imageView.clipsToBounds = true
               return imageView
           }()
           
           let statusTextView: UITextView = {
               let textView = UITextView()
            textView.backgroundColor = .white
               textView.font = UIFont.systemFont(ofSize: 14)
               textView.isScrollEnabled = false
               return textView
           }()
           
           let statusImageView: UIImageView = {
               let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
               imageView.layer.masksToBounds = true
               imageView.isUserInteractionEnabled = true
               return imageView
           }()
           
           let likesLabel: UILabel = {
               let label = UILabel()
               label.font = UIFont.systemFont(ofSize: 12)
            label.text = "Like"
            label.isUserInteractionEnabled = true
            let labelTap = UITapGestureRecognizer(target: self, action: #selector(handleLike))
            label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            label.addGestureRecognizer(labelTap)
               return label
           }()
    
        let commentLabel: UILabel = {
            let label = UILabel()
            label.text = "Comment"
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            return label
        }()
           
        let dividerLineView: UIView = {
               let view = UIView()
               view.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                view.heightAnchor.constraint(equalToConstant: 2).isActive = true
               return view
           }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        return label
    }()
    
    @objc func handleLike() {
        print("Sup sup")
        partyPageController?.handleLike(cell: self)
    }
    
}
