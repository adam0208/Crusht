//
//  ViewController.swift
//  Crusht
//
//  Created by William Kelly on 12/5/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import JGProgressHUD

class LocationMatchViewController: UIViewController, CardViewDelegate {
 
    let bottomStackView = LocationMatchBottomButtonsStackView()
    let topStackView = LocationMatchTopStackView()
    let cardDeckView = UIView()
    
    var cardViewModels = [CardViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topStackView.homeButton.addTarget(self, action: #selector(handleHomeBttnTapped), for: .touchUpInside)
        bottomStackView.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        setupLayout()
        
        bottomStackView.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        
        bottomStackView.dislikeButton.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
        fetchCurrentUser()
        //fetchUsersFromFirestore()
        //fetchUsersOnLoad()
        fetchUsersOnLoad()

        
    }
    
 
    
    fileprivate var user: User?
    
    fileprivate func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            
            guard let dictionary = snapshot?.data() else {return}
            self.user = User(dictionary: dictionary)
            
            self.fetchSwipes()
            //self.fetchUsersFromFirestore()
        }
    }
    
    var swipes = [String: Int]()
    
    fileprivate func fetchSwipes() {
        guard let uid = Auth.auth().currentUser?.uid  else {
            return
        }
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("failed to fetch swipe info", err)
                return
            }
            print("Swipes", snapshot?.data() ?? "")
            guard let data = snapshot?.data() as? [String: Int] else {return}
            self.swipes = data
           // self.fetchUsersFromFirestore()
            self.fetchUsersOnLoad()
        }
    }
    
    @objc func handleHomeBttnTapped() {
        let profPageController = ProfilePageViewController()
        present(profPageController, animated: true)
    }
    
    fileprivate func setupFirestoreUserCards() {
        
            cardViewModels.forEach { (cardVM) in
            let cardView = CardView(frame: .zero)
            
            cardView.cardViewModel = cardVM
            
            cardDeckView.addSubview(cardView)
            cardView.fillSuperview()
        }
    }
    
    var lastFetchedUser: User?
    let hud = JGProgressHUD(style: .dark)
    
     func fetchUsersFromFirestore() {
        hud.textLabel.text = "Fetching Users, hold tight :)"
        hud.show(in: view)
        hud.dismiss(afterDelay: 1)
        
        let minAge = user?.minSeekingAge ?? 18
        let maxAge = user?.maxSeekingAge ?? 50
        
        print(maxAge)
        
        let query = Firestore.firestore().collection("users").whereField("Age", isGreaterThanOrEqualTo: minAge).whereField("Age", isLessThanOrEqualTo: maxAge)
        //order(by: "uid").start(after: [lastFetchedUser?.uid ?? ""]).limit(to: 2)
        topCardView = nil
        query.getDocuments { (snapshot, err) in
            if let err = err {
                print("failed to fetch user", err)
                self.hud.textLabel.text = "Failed To Fetch user"
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2)
                return
            }
            
            var previousCardView: CardView?
            
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let user = User(dictionary: userDictionary)
               // if user.uid != Auth.auth().currentUser?.uid {
                let isNotCurrentUser = user.uid != Auth.auth().currentUser?.uid
                let hasNotSwipedBefore = self.swipes[user.uid!] == nil
                if isNotCurrentUser && hasNotSwipedBefore  {
                    let cardView = self.setupCardFromUser(user: user)
                    
                    previousCardView?.nextCardView = cardView
                    previousCardView = cardView
                    
                    if self.topCardView == nil {
                        self.topCardView = cardView
                    }
                }
               
            })
            
        }
    }
    
    var topCardView: CardView?
    
    @objc func handleLike() {
        
        saveSwipeToFireStore(didLike: 1)
        
        performSwipeAnimation(translation: 700, angle: 15)
        
    }
    
    fileprivate func saveSwipeToFireStore(didLike: Int) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        guard let cardUID = topCardView?.cardViewModel.uid  else {
            return
        }
        
        let documentData = [cardUID: didLike]
        
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("Failed to fetch swipe doc", err)
                return
            }
            if snapshot?.exists == true {
                Firestore.firestore().collection("swipes").document(uid).updateData(documentData) { (err) in
                    if let err = err {
                        print("failed to save swipe", err)
                        return
                    }
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                    print("Success")
                }
            } else {
                Firestore.firestore().collection("swipes").document(uid).setData(documentData) { (err) in
                    if let err = err {
                        print("Error", err)
                        return
                    }
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                    print("Success saved swipe SETDATA")
                }
            }
        }
     
    }
    
    fileprivate func checkIfMatchExists(cardUID: String) {
        
        print("Match detection")
        
        Firestore.firestore().collection("swipes").document(cardUID).getDocument { (snapshot, err) in
            if let err = err {
                print("Failed to fetch doc for card user", err)
                return
            }
            guard let data = snapshot?.data() else {return}
            print(data)
            
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let hasMatched = data[uid] as? Int == 1
            if hasMatched {
                print("we have a match!")
                self.presentMatchView(cardUID: cardUID)
            }
        }
    
    }
    
    fileprivate func presentMatchView(cardUID: String) {
        let matchView = MatchView()
        matchView.cardUID = cardUID
        matchView.currentUser = self.user
        view.addSubview(matchView)
        matchView.fillSuperview()
    }
    
    @objc func handleDislike() {
        saveSwipeToFireStore(didLike: 0)
        performSwipeAnimation(translation: -700, angle: -15)
        
    }
    
    fileprivate func performSwipeAnimation(translation: CGFloat, angle: CGFloat) {
        let duration = 0.5
        let translationAnimation = CABasicAnimation(keyPath: "position.x")
        translationAnimation.toValue = translation
        translationAnimation.duration = duration
        translationAnimation.fillMode = .forwards
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translationAnimation.isRemovedOnCompletion = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = angle * CGFloat.pi / 180
        rotationAnimation.duration = duration
        
        let cardView = topCardView
        topCardView = cardView?.nextCardView
        
        CATransaction.setCompletionBlock {
            cardView?.removeFromSuperview()
        }
        
        cardView?.layer.add(translationAnimation, forKey: "translation")
        cardView?.layer.add(rotationAnimation, forKey: "rotation")
        
        CATransaction.commit()
    }
    
    func didRemoveCard(cardView: CardView) {
        self.topCardView?.removeFromSuperview()
        self.topCardView = self.topCardView?.nextCardView
    }
    
    fileprivate func setupCardFromUser(user: User) -> CardView {
        let cardView = CardView(frame: .zero)
        cardView.delegate = self
        cardView.cardViewModel = user.toCardViewModel()
        
        cardDeckView.addSubview(cardView)
        cardDeckView.sendSubviewToBack(cardView)

        cardView.fillSuperview()
        return cardView
    }
    
    func didTapMoreInfo(cardViewModel: CardViewModel) {
       let userDetailsController = UserDetailsController()
        //userDetailsController.view.backgroundColor = .purple
        userDetailsController.cardViewModel = cardViewModel
        present(userDetailsController, animated: true)
    }
    
    @objc fileprivate func handleRefresh() {
        cardDeckView.subviews.forEach({$0.removeFromSuperview()})
        fetchUsersFromFirestore()
    }
    
    //func bellow handles fetchusers on load -little improv
    fileprivate func fetchUsersOnLoad() {
        cardDeckView.subviews.forEach({$0.removeFromSuperview()})
        fetchUsersFromFirestore()
    }
    
    //MARK:- Fileprivate
    
    fileprivate func setupLayout() {
        
        view.backgroundColor = .white
        
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardDeckView, bottomStackView])
        overallStackView.axis = .vertical
        
        view.addSubview(overallStackView)
        
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        
        overallStackView.bringSubviewToFront(cardDeckView)
    }
    

}

