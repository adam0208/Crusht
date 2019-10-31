//
//  ChatLogController.swift
//  Crusht
//
//  Created by William Kelly on 12/15/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//
import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

private let reuseIdentifier = "Cell"

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UITextViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var messages = [Message]()
    var fromName: String?
    
    let messageController = MessageController()
    var containerViewBottomAnchor: NSLayoutConstraint?
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    var timer: Timer?
    
    let cellId = "cellId"
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            if messages.isEmpty == true {
                self.observeSentMessages()
                self.observeReceivedMessages()
            } else {
                messages.removeAll()
                self.observeSentMessages()
                self.observeReceivedMessages()
            }
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }

    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listenForMessages()
        navigationController?.navigationBar.isTranslucent = false
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        navigationItem.leftBarButtonItems = [UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-back-filled-30-2").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleback)), UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-remove-30").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(deleteConvo))]
                
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 10, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .onDrag
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-exclamation-mark-30").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleReport)), UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-user-male-30").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(goToProfile))]

        setupKeyboardObservers()
        collectionView.bringSubviewToFront(inputContainerView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.setToolbarHidden(false, animated: animated)
        self.navigationController?.toolbar.backgroundColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
        self.navigationController?.toolbar.isTranslucent = false
        self.navigationController?.toolbar.barTintColor = #colorLiteral(red: 0, green: 0.1882352941, blue: 0.4588235294, alpha: 1)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Logic
    
    @objc fileprivate func deleteConvo() {
        let alert = UIAlertController(title: "Delete Match", message: "Delete your match with \(navigationItem.title ?? "this user")?", preferredStyle: .alert)
        let action = UIAlertAction(title: "Delete", style: .default){(UIAlertAction) in
            let toId = self.user!.uid!
            let fromId = Auth.auth().currentUser!.uid
            Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: toId).whereField("toId", isEqualTo: fromId).getDocuments(completion: { (snapshot, err) in
                if err != nil {
                    self.handleback()
                    return
                }
                snapshot?.documents.forEach({ (documentSnapshot) in
                    
                    let docID = documentSnapshot.documentID
                    Firestore.firestore().collection("messages").document(docID).delete()
                     MessageController.sharedInstance?.didHaveNewMessage = true
                    self.deleteConvoPart2()
                })
            })
        }
        let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    fileprivate func deleteConvoPart2() {
        let toId = user!.uid!
        let fromId = Auth.auth().currentUser!.uid
        Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: fromId).whereField("toId", isEqualTo: toId).getDocuments(completion: { (snapshot, err) in
            if err != nil {
                self.handleback()
                return
            }
            snapshot?.documents.forEach({ (documentSnapshot) in
                    let docID = documentSnapshot.documentID
                    Firestore.firestore().collection("messages").document(docID).delete()
                    self.handleback()
                })
            })
        }
    
    func observeSentMessages() {
        let toId = user!.uid!
        let fromId = Auth.auth().currentUser!.uid
        observeMessages(fromId: fromId, toId: toId)
    }
    
    func observeReceivedMessages() {
        let toId = Auth.auth().currentUser!.uid
        let fromId = user!.uid!
        observeMessages(fromId: fromId, toId: toId)
    }
    
    func observeMessages(fromId: String, toId: String) {
        Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: fromId).whereField("toId", isEqualTo: toId).getDocuments(completion: { (snapshot, err) in
            if err != nil {
                self.handleback()
                return
            }
            let downloadGroup = DispatchGroup()
            snapshot?.documents.forEach({ (documentSnapshot) in
                downloadGroup.enter()
                Firestore.firestore().collection("messages").document(documentSnapshot.documentID).collection("user-messages").getDocuments(completion: { (snapshot, err) in
                    snapshot?.documents.forEach({ (documentSnapshot) in
                        if err != nil {
                            self.handleback()
                            downloadGroup.leave()
                            return
                        }
                        
                        let userDictionary = documentSnapshot.data()
                        let message = Message(dictionary: userDictionary)
                        if message.chatPartnerId() == self.user?.uid {
                            self.messages.append(message)
                        }
                    })
                    downloadGroup.leave()
                })
            })
            downloadGroup.notify(queue: .main) {
                self.messages.sort { $0.timestamp?.int32Value ?? 0 < $1.timestamp?.int32Value ?? 0 }
                self.collectionView?.reloadData()
                let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
            }
        })
    }
    
    fileprivate func listenForMessages() {
        let toId = user!.uid!
        Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: toId).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                return
            }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .modified) {
                    self.messages.removeAll()
                    self.observeSentMessages()
                    self.observeReceivedMessages()
                }
            }
        }
    }
    
    @objc fileprivate func goToProfile() {
        let userDetailsController = UserDetailsController()
        let myBackButton = UIBarButtonItem()
        myBackButton.title = " "
        navigationItem.backBarButtonItem = myBackButton
        userDetailsController.cardViewModel = user!.toCardViewModel()
        navigationController?.pushViewController(userDetailsController, animated: true)
    }
    
    @objc fileprivate func handleReport() {
        let reportController = MessageReportController()
        reportController.reportPhoneNumebr = user?.phoneNumber ?? ""
        reportController.reportUID = user?.uid ?? ""
        reportController.reportName = user?.name ?? ""
        reportController.uid = Auth.auth().currentUser!.uid
        
        let myBackButton = UIBarButtonItem()
        myBackButton.title = " "
        navigationItem.backBarButtonItem = myBackButton
        navigationController?.pushViewController(reportController, animated: true)
    }
    
    @objc func handleReloadTable() {
        messages.removeAll()
        self.observeSentMessages()
        self.observeReceivedMessages()
    }
    
    
    @objc func handleback() {
        self.inputContainerView.alpha = 0
        self.navigationController?.setToolbarHidden(true, animated: true)
        self.dismiss(animated: true)

    }
    
    @objc fileprivate func handleStubTapped() {
        if let url = URL(string: "https://www.stubhub.com"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @objc fileprivate func handleOpenTableTapped() {
        if let url = URL(string: "https://www.opentable.com"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
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
                        self.sendMessageWithProperties(properties as [String : AnyObject])
                        
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
            self.navigationItem.title = self.user?.name
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
            self.inputTextField.text = nil
            uploadToFirebaseStorageUsingImage(selectedImage, completion: { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl, image: selectedImage)
            })
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
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    @objc func handleKeyboardDidShow() {
        if messages.isEmpty == false {
        
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
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
    
    fileprivate func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: 16)]), context: nil)
    }
    
    @objc func handleSend() {
        let properties = ["text": inputTextField.text!]
        sendMessageWithProperties(properties as [String : AnyObject])
    }
    
    fileprivate func sendMessageWithImageUrl(_ imageUrl: String, image: UIImage) {
        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject, "text": "Image" as AnyObject]
        inputTextField.text = nil
        sendMessageWithProperties(properties)
    }
    
    fileprivate func sendMessageWithProperties(_ properties: [String: AnyObject]) {
        // Is it there best thing to include the name inside of the message node
        let toId = user!.uid!
        let fromId = Auth.auth().currentUser!.uid
        let toName = user?.name ?? ""
        let timestamp = Int(Date().timeIntervalSince1970)
        
        var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "fromName": self.fromName as AnyObject, "toName": toName as AnyObject, "timestamp": timestamp as AnyObject]
        properties.forEach({values[$0] = $1})
        
        // Flip to id and from id to fix message controller query glitch
        var otherValues:  [String: AnyObject] = ["toId": fromId as AnyObject, "fromId": toId as AnyObject, "fromName": user?.name as AnyObject, "toName": self.fromName as AnyObject, "timestamp": timestamp as AnyObject]
        properties.forEach({otherValues[$0] = $1})
        
        self.inputTextField.text = nil
                
        // SOLUTION TO CURRENT ISSUE
        // If statement whether this document exists or not and IF It does than user-message thing, if it doesn't then we create a document
        Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: fromId).whereField("toId", isEqualTo: toId).getDocuments(completion: { (snapshot, err) in
            if err != nil {
                return
            }
            if (snapshot?.isEmpty)! {
                Firestore.firestore().collection("messages").addDocument(data: values) { (err) in
                    if err != nil {
                        return
                    }
                    
                    Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: fromId).whereField("toId", isEqualTo: toId).getDocuments(completion: { (snapshot, err) in
                        if err != nil {
                            return
                        }
                        
                        snapshot?.documents.forEach({ (documentSnapshot) in
                            let document = documentSnapshot
                            if document.exists {
                                Firestore.firestore().collection("messages").document(documentSnapshot.documentID).collection("user-messages").addDocument(data: values)
                                self.messages.removeAll()
                                self.observeReceivedMessages()
                                self.observeSentMessages()
                            } else{
                                print("DOC DOESN't exist yet")
                            }
                        })
                    })
                }
            } else {
                snapshot?.documents.forEach({ (documentSnapshot) in
                    let document = documentSnapshot
                    if document.exists {
                        Firestore.firestore().collection("messages").document(documentSnapshot.documentID).collection("user-messages").addDocument(data: values)
                        // Message row update fix
                        
                        // Sort a not to update from id stuff
                        Firestore.firestore().collection("messages").document(documentSnapshot.documentID).updateData(values)
                        
                        // Flip it
                        Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: toId).whereField("toId", isEqualTo: fromId).getDocuments(completion: { (snapshot, err) in
                            if err != nil {
                                return
                            }
                            
                            snapshot?.documents.forEach({ (documentSnapshot) in
                                
                                let document = documentSnapshot
                                if document.exists {
                                    Firestore.firestore().collection("messages").document(documentSnapshot.documentID).updateData(otherValues)
                                }
                            })
                        })
                    }
                })
            }
        })
        
        // Cloud messaging stuff
        messages.removeAll()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    func performZoomInForStartingImageView(_ startingImageView: UIImageView) {
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                
            }, completion: { (completed) in
                // Do nothing
            })
            
        }
    }
    
    @objc func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            // Need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        cell.chatLogController = self
        if !messages.isEmpty {
            let message = messages[indexPath.item]
            let widthForText = message.text != nil ? estimateFrameForText(message.text!).width + 32 : nil
            cell.setup(message: message, currentUserId: Auth.auth().currentUser?.uid, userImageUrl: self.user?.imageUrl1, widthForText: widthForText)
        }
        else {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        let message = messages[indexPath.item]
        if message.text != "Image" {
            if let text = message.text {
                height = estimateFrameForText(text).height + 20
            }
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row > messages.count - 1 {
            observeSentMessages()
            observeReceivedMessages()
        }
    }
    
    // MARK: - User Interface
    
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
    
    lazy var inputContainerView: UIView = {
        // Need to fix for iphone x
        let containerView = CustomView()
        
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = false
        uploadImageView.image = UIImage(named: "icons8-communication-30")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
//        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        containerView.addSubview(uploadImageView)
        
        //x,y,w,h
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: UIControl.State())
        sendButton.titleLabel?.adjustsFontForContentSizeCategory = true
        
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(self.inputTextField)
        
        self.inputTextField.anchor(top: containerView.topAnchor, leading: uploadImageView.trailingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: .init(top: 8, left: 0, bottom: 0, right: 90))
        
        sendButton.anchor(top: nil, leading: self.inputTextField.trailingAnchor, bottom: nil, trailing: containerView.trailingAnchor)
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
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
