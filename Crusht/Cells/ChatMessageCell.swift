//
//  ChatMessageCell.swift
//  Crusht
//
//  Created by William Kelly on 12/19/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import AVFoundation
import Nuke
//import SDWebImage


class ChatMessageCell: UICollectionViewCell {
    static let pinkColor = #colorLiteral(red: 1, green: 0, blue: 0.6713966727, alpha: 1)
    var message: Message?
    var chatLogController: ChatLogController?
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        
        bubbleView.addSubview(messageImageView)
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
        //x,y,w,h
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        //x,y,w,h
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleViewRightAnchor?.isActive = true
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        // bubbleViewLeftAnchor?.active = false
        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //ios 9 constraints
        //x,y,w,h
        // textView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        // textView.widthAnchor.constraintEqualToConstant(200).active = true
        
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true

        bubbleView.addSubview(playButton)
        //x,y,w,h
        playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        bringSubviewToFront(playButton)
    }
   
   override func prepareForReuse() {
       super.prepareForReuse()
       playerLayer?.removeFromSuperlayer()
       player?.pause()
       activityIndicatorView.stopAnimating()
   }
    
    @objc private func handlePlay() {
        guard let videoUrlString = message?.videoUrl, let url = URL(string: videoUrlString) else { return }

        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = bubbleView.bounds
        bubbleView.layer.addSublayer(playerLayer!)
        
        player?.play()
        activityIndicatorView.startAnimating()
        playButton.isHidden = true
   }
   
   @objc private func handleZoomTap(_ tapGesture: UITapGestureRecognizer) {
       guard message?.videoUrl == nil, let imageView = tapGesture.view as? UIImageView else { return }
       endEditing(true)
       //PRO Tip: don't perform a lot of custom logic inside of a view class
       self.chatLogController?.performZoomInForStartingImageView(imageView)
   }
    
    func setup(message: Message, currentUserId: String?, userImageUrl: String?, widthForText: CGFloat?) {
        self.message = message
        textView.text = message.text
        
        // This is needed to avoid showing the wrong image while the actual one is being downloaded.
        // The problem is caused by cell reuse.
        self.profileImageView.image = nil
        
        if let userImageUrl = userImageUrl {
            let url = URL(string: userImageUrl)
            Nuke.loadImage(with: url!, into: self.profileImageView)
//            SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
//                self.profileImageView.image = image
//            }
            
            if message.fromId == currentUserId {
                //outgoing pink
                bubbleView.backgroundColor = ChatMessageCell.pinkColor
                textView.textColor = UIColor.white
                profileImageView.isHidden = true
                
                bubbleViewRightAnchor?.isActive = true
                bubbleViewLeftAnchor?.isActive = false
            } else {
                //incoming gray
                bubbleView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                textView.textColor = UIColor.black
                profileImageView.isHidden = false
                
                bubbleViewRightAnchor?.isActive = false
                bubbleViewLeftAnchor?.isActive = true
            }
            
            if let messageImageUrl = message.imageUrl {
                if message.text == "Image" {
                    let url = URL(string: messageImageUrl)
                    
                    Nuke.loadImage(with: url!, into: self.messageImageView)
                    self.textView.text = ""
                    self.messageImageView.isHidden = false
                    self.bubbleView.backgroundColor = UIColor.clear
                    
//                    SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
//                        self.messageImageView.image = image
//                        self.textView.text = ""
//                        self.messageImageView.isHidden = false
//                        self.bubbleView.backgroundColor = UIColor.clear
//                    }
                }
            } else {
                messageImageView.isHidden = true
            }
        }
        
        if message.text != "Image" {
            if let widthForText = widthForText {
                // A text message
                bubbleWidthAnchor?.constant = widthForText
                textView.isHidden = false
            }
        } else if message.imageUrl != nil {
            // Fall in here if its an image message
            bubbleWidthAnchor?.constant = 200
            textView.isHidden = true
        }
        
        playButton.isHidden = message.videoUrl == nil
    }
    
    // MARK: - User Interface
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "play")
        button.tintColor = UIColor.white
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return button
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "SAMPLE TEXT FOR NOW"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.textColor = .white
        tv.isEditable = false
        return tv
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = pinkColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return imageView
    }()
    
}
