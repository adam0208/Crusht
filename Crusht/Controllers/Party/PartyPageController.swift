//
//  PartyPageController.swift
//  Crusht
//
//  Created by William Kelly on 2/19/20.
//  Copyright © 2020 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import MobileCoreServices
import AVFoundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage


private let reuseIdentifier = "Cell"

class PartyPageController: UICollectionViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout{
    let cellId = "cellId"
    var party: Party?
    var posts: Post?
    var postsArray = [Post]()
    var containerViewBottomAnchor: NSLayoutConstraint?
    var user: User?

        
//        let likeButton = FeedCell.buttonForTitle("Like", imageName: "like")
//        let commentButton: UIButton = FeedCell.buttonForTitle("Comment", imageName: "comment")
//        let shareButton: UIButton = FeedCell.buttonForTitle("Share", imageName: "share")
        
//        static func buttonForTitle(_ title: String, imageName: String) -> UIButton {
//            let button = UIButton()
////            button.setTitle(title, for: UIControlState())
////            button.setTitleColor(UIColor.rgb(143, green: 150, blue: 163), for: UIControlState())
////
////            button.setImage(UIImage(named: imageName), for: UIControlState())
////            button.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0)
////
//            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
//
//            return button
//        }
       
//        func setupViews() {
//            collectionView.backgroundColor = UIColor.white
//            navigationItem.title = "\(party?.partyName ?? "") Page"
//
//
//            navigationItem.rightBarButtonItems = [guestButton, editButton]
////            collectionView.addSubview(nameLabel)
////            collectionView.addSubview(profileImageView)
////            collectionView.addSubview(statusTextView)
////            collectionView.addSubview(statusImageView)
////            collectionView.addSubview(likesCommentsLabel)
////            collectionView.addSubview(dividerLineView)
//            collectionView.backgroundColor = .white
//            //collectionView.addSubview(likeButton)
//                // collectionView.addSubview(commentButton)
//           // collectionView.addSubview(shareButton)
//
//          //  statusImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FeedCell.animate as (FeedCell) -> () -> ())))
//
////            nameLabel.anchor(top: collectionView.topAnchor, leading: collectionView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 20, left: 20, bottom: 0, right: 0))
////            nameLabel.text = "Hi Yo"
//
//
////            collectionView.addConstraintsWithFormat("V:|-8-[v0(44)]-4-[v1]-4-[v2(200)]-8-[v3(24)]-8-[v4(0.4)][v5(44)]|", views: profileImageView, statusTextView, statusImageView, likesCommentsLabel, dividerLineView, likeButton)
////
////            collectionView.addConstraintsWithFormat("V:[v0(44)]|", views: commentButton)
////            collectionView.addConstraintsWithFormat("V:[v0(44)]|", views: shareButton)
//        }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.delegate = self
        let guestButton = UIBarButtonItem(title: "Guests", style: .plain, target: self, action: #selector(handleGuests))
               let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(handleEdits))
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        navigationItem.title = "\(party?.partyName ?? "") Page"
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
         collectionView.backgroundColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
        if uid == party?.hostUID {
            navigationItem.rightBarButtonItems = [guestButton, editButton]
        }
        else {
            navigationItem.rightBarButtonItem = guestButton
        }
        collectionView?.keyboardDismissMode = .onDrag
         navigationItem.rightBarButtonItems = [guestButton, editButton]
        collectionView?.register(PartyPageCell.self, forCellWithReuseIdentifier: cellId)
        inputAccessoryView?.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        
        
        setupKeyboardObservers()
        fetchPosts()
        
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    @objc func handleKeyboardDidShow() {
        if postsArray.isEmpty == false {
        
        if postsArray.count > 0 {
            let indexPath = IndexPath(item: 0, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
            }
        } else {
            DispatchQueue.main.async(execute: {
                self.collectionView?.reloadData()
            })
        }
    }
    @objc func handleKeyboardWillShow(_ notification: Notification) {
        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func handleKeyboardWillHide(_ notification: Notification) {
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    fileprivate func handleTapDismiss() {
        self.view.endEditing(true)
    }

    
    @objc fileprivate func handleGuests() {
        print("yo")
        let guestController = GuestsController()
        let myBackButton = UIBarButtonItem()
        myBackButton.title = " "
        self.navigationItem.backBarButtonItem = myBackButton
        guestController.party = self.party
        self.navigationController?.pushViewController(guestController, animated: true)
    }
    
    @objc fileprivate func handleEdits() {
     
            let editPartyController = EditPartyController()
        editPartyController.party = self.party
        let navController = UINavigationController(rootViewController: editPartyController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
        }
    
    
    fileprivate func fetchPosts() {
        Firestore.firestore().collection("parties").document(party?.partyUID ?? "").collection("posts").getDocuments { (snapshot, err) in
            if let err = err {
                print("Fuck", err)
            }
            if snapshot!.isEmpty {
                print("empty")
            }
            snapshot?.documents.forEach({ (docSnapshot) in
                let dictionary = docSnapshot.data()
                let userPosts = Post(dictionary: dictionary)
                self.postsArray.append(userPosts)
                print(self.postsArray)
                print(userPosts.postOwnerName ?? "")
                self.postsArray.sort { $0.timestamp?.int32Value ?? 0 > $1.timestamp?.int32Value ?? 0 }
                          DispatchQueue.main.async {
                              self.collectionView.reloadData()
                          }
                self.collectionView.reloadData()
            })
        }
    }
    
    
    lazy var inputTextField: UITextView = {
        let textView = UITextView()
        textView.text = ""
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.isEditable = true
        
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.adjustsFontForContentSizeCategory = true
        func adjustUITextViewHeight(arg : UITextView) {
            arg.translatesAutoresizingMaskIntoConstraints = true
            arg.sizeToFit()
            arg.isScrollEnabled = false
        }
        func textViewDidBeginEditing(_ textView: UITextView) {
            textView.text = nil
        }
        
        return textView
    }()
    
    let photoImageView = UIImageView()
            
    
    @objc func handleLike(cell: PartyPageCell) {
        
        if cell.likesLabel.tintColor != #colorLiteral(red: 1, green: 0.6745098039, blue: 0.7215686275, alpha: 1) {
        
        guard let indexPathTapped = collectionView.indexPath(for: cell) else { return }
        let post = postsArray[indexPathTapped.item]
        
        Firestore.firestore().collection("parties").document(party?.partyUID ?? "").collection("posts").document(post.postID ?? "").getDocument { (docSnap, err) in
            if let err = err {
                print(err, "No no")
            }
            guard let postDict = docSnap?.data() else {return}
            let post = Post(dictionary: postDict)
            
            let newLikes = (post.postLikes ?? 0) + 1
            
            let docData: [String: Any] = ["postLikes": newLikes]
                
            Firestore.firestore().collection("parties").document(self.party?.partyUID ?? "").collection("posts").document(post.postID ?? "").updateData(docData)
            
            cell.likesLabel.tintColor = #colorLiteral(red: 1, green: 0.6745098039, blue: 0.7215686275, alpha: 1)
                            
            self.reloadPosts()
            }
        }
          
    }
    
    @objc func handleComment(cell: UICollectionViewCell) {
        
    }
    
    lazy var containerView: UIView = {
        let containerView = CustomView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50)
        containerView.backgroundColor = UIColor.white
        return containerView
    }()
    
        lazy var inputContainerView: UIView = {
            // Need to fix for iphone x
            let uploadImageView = UIImageView()
                      uploadImageView.isUserInteractionEnabled = true
                      uploadImageView.image = #imageLiteral(resourceName: "upload_image_icon-1")
                      uploadImageView.translatesAutoresizingMaskIntoConstraints = false
                      uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
                      containerView.addSubview(uploadImageView)
            
            let postButton = UIButton(type: .system)
                      postButton.setTitle("Post", for: UIControl.State())
                      postButton.titleLabel?.adjustsFontForContentSizeCategory = true
                      
                      postButton.addTarget(self, action: #selector(handlePost), for: .touchUpInside)
                      containerView.addSubview(postButton)
            
            let separatorLineView = UIView()
                  separatorLineView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                  separatorLineView.translatesAutoresizingMaskIntoConstraints = false
                  containerView.addSubview(separatorLineView)
            
             containerView.addSubview(self.inputTextField)
            
            //x,y,w,h
            uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
            uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
            
            //x,y,w,h
            postButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
            postButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            postButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
            postButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
            
            self.inputTextField.anchor(top: containerView.topAnchor, leading: uploadImageView.trailingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: .init(top: 8, left: 0, bottom: 0, right: 80))
            
            postButton.anchor(top: nil, leading: self.inputTextField.trailingAnchor, bottom: nil, trailing: containerView.trailingAnchor)
            
            //x,y,w,h
            separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
            separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            return containerView
        }()
    
    @objc func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           // Local variable inserted by Swift 4.2 migrator.
           let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
           
           if let videoUrl = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as? URL {
               // We selected a video
               handleVideoSelectedForUrl(videoUrl)
           } else {
               // We selected an image
            
               handleImageSelectedForInfo(info as [String : AnyObject])
           }
           
           dismiss(animated: true, completion: nil)
       }
    
    fileprivate func selectImage(image: UIImage, _ info: [String: AnyObject]) {
//        let renderer = UIGraphicsImageRenderer(size: view.frame.size)
//        let image = renderer.image {
//            view.layer.render(in: $0.cgContext)
//        }
      let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(origin: .zero, size: image.size)
        let currentAtStr = NSMutableAttributedString(attributedString: inputTextField.attributedText)
        let attachmentAtStr = NSAttributedString(attachment: attachment)
        if let selectedRange = inputTextField.selectedTextRange {
            let cursorIndex = inputTextField.offset(from: inputTextField.beginningOfDocument, to: selectedRange.start)
            currentAtStr.insert(attachmentAtStr, at: cursorIndex)

             // Workaround that causes different font after the attachment image, https://stackoverflow.com/questions/21742376
            currentAtStr.addAttributes(inputTextField.typingAttributes, range: NSRange(location: cursorIndex, length: 1))
        } else {
            currentAtStr.append(attachmentAtStr)
        }
        inputTextField.attributedText = currentAtStr
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300)
        //handleImageSelectedForInfo(info as [String : AnyObject])
    }
       
       fileprivate func handleVideoSelectedForUrl(_ url: URL) {
           let filename = UUID().uuidString + ".mov"
           let ref = Storage.storage().reference().child("message_movies").child(filename)
           let uploadTask = ref.putFile(from: url, metadata: nil, completion: { (_, err) in
               if err != nil {
                   return
               }
               
               ref.downloadURL(completion: { (downloadUrl, err) in
                   if err != nil {
                       return
                   }
                   
                   guard let downloadUrl = downloadUrl else { return }
                   if let thumbnailImage = self.thumbnailImageForFileUrl(url) {
                       self.uploadToFirebaseStorageUsingImage(thumbnailImage, completion: { (imageUrl) in
                           let properties: [String: Any] = ["imageUrl": imageUrl, "imageWidth": thumbnailImage.size.width, "imageHeight": thumbnailImage.size.height, "videoUrl": downloadUrl.absoluteString]
                          // self.sendMessageWithProperties(properties as [String : AnyObject])
                           
                       })
                   }
                   
               })
           })
           uploadTask.observe(.progress) { (snapshot) in
               if let completedUnitCount = snapshot.progress?.completedUnitCount {
                   self.navigationItem.title = String(completedUnitCount)
               }
           }
           
           uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.party?.partyName ?? ""
           }
       }
       
       fileprivate func thumbnailImageForFileUrl(_ fileUrl: URL) -> UIImage? {
           let asset = AVAsset(url: fileUrl)
           let imageGenerator = AVAssetImageGenerator(asset: asset)
           
           do {
               let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
               return UIImage(cgImage: thumbnailCGImage)
           } catch let err {
               print(err)
           }
           return nil
       }
       
       fileprivate func handleImageSelectedForInfo(_ info: [String: AnyObject]) {
           var selectedImageFromPicker: UIImage?
           
           if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
               selectedImageFromPicker = editedImage
           } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
               selectedImageFromPicker = originalImage
           }
           
           if let selectedImage = selectedImageFromPicker {
           selectImage(image: selectedImage, info)
              // uploadToFirebaseStorageUsingImage(selectedImage, completion: { (imageUrl) in
                  // self.sendMessageWithImageUrl(imageUrl, image: selectedImage)
              // })
           }
       }
       
       fileprivate func uploadToFirebaseStorageUsingImage(_ image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
           let imageName = UUID().uuidString
           let ref = Storage.storage().reference().child("message_images").child(imageName)
           
           if let uploadData = image.jpegData(compressionQuality: 0.2) {
               ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                   
                   if error != nil {
                       return
                   }
                   ref.downloadURL(completion: { (url, err) in
                       if err != nil {
                           return
                       }
                       completion(url?.absoluteString ?? "")
                   })
               })
           }
       }
       
       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           dismiss(animated: true, completion: nil)
       }
    fileprivate func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
      }
    @objc fileprivate func handlePost() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let postID = randomString(length: 20)
        let timestamp = Int(Date().timeIntervalSince1970)
        
         let docData: [String: Any] = ["postOwnerUID": uid,
                                             "postID": postID,
                                             "postOwnerName": user?.name ?? "",
                                             "postLikes": 0,
                                             "postNumberOfComments": 0,
                                             "postImageUrl": "",
                                             "postText": self.inputTextField.text ?? "",
                                             "postOwnerProfileImageURL": user?.imageUrl1 ?? "",
                                            "timestamp": timestamp,
                                            "imageWidth": 0,
                                            "imageHeight": 0
                                            ]
        
        Firestore.firestore().collection("parties").document(party?.partyUID ?? "").collection("posts").document(postID).setData(docData)
        self.inputTextField.text = ""
        self.reloadPosts()
      
    }
    
    @objc fileprivate func reloadPosts () {
        postsArray.removeAll()
           fetchPosts()
           DispatchQueue.main.async {
                self.collectionView.refreshControl?.endRefreshing()
             }
       }
    
    fileprivate func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: 16)]), context: nil)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return postsArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PartyPageCell
        cell.partyPageController = self
        let post = postsArray[indexPath.item]
        cell.setupCell(post: post)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 100
        let post = postsArray[indexPath.item]
        if post.postImageUrl != "" {
             let text = post.postText            
            //let imageWidth = post.imageWidth?.floatValue
            let imageHeight = post.imageHeight?.floatValue
            height = CGFloat(CGFloat(imageHeight ?? 0)) + CGFloat(estimateFrameForText(text ?? "").height + 50)
            }
        else {
            let text = post.postText
            height = estimateFrameForText(text ?? "").height + 110
        }
        
        print(height, "Yuck Yo Yo")

        return CGSize(width: view.bounds.width, height: height)
      }
      
    
   

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}

private class CustomView: UIView {
    // This is needed so that the inputAccesoryView is properly sized from the auto layout constraints
    // Actual value is not important
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if #available(iOS 11.0, *) {
            if let window = self.window {
                self.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: window.safeAreaLayoutGuide.bottomAnchor, multiplier: 0.1).isActive = true
            }
        }
    }
}


