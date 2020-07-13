//
//  TutorialController.swift
//  Crusht
//
//  Created by William Kelly on 6/30/20.
//  Copyright © 2020 William Kelly. All rights reserved.
//

import UIKit

class TutorialController: UIViewController {
    
    let firstImage = UIImage(named: "venuesWITHOUTCOLOR.png")
   // let secondImage = UIImage(named: "PartiesUPDATED.png")
    let thirdImage = UIImage(named: "SchoolOG.png")
    let fourthImage = UIImage(named: "ContactsUPDATED.png")
    let fifthImage = UIImage(named: "locationUPDATED-0.png")
    let sixthImage = UIImage(named: "messagesUPDATED.png")
    
    let firstView: UIButton = {
        let view = UIButton(type: .system)
        view.addTarget(self, action: #selector(dismissView1), for: .touchUpInside)
        
         return view
    }()
//    let secondView: UIButton = {
//        let view = UIButton(type: .system)
//        view.addTarget(self, action: #selector(dismissView2), for: .touchUpInside)
//
//         return view
//    }()
    let thirdView: UIButton = {
        let view = UIButton(type: .system)
        view.addTarget(self, action: #selector(dismissView3), for: .touchUpInside)
        
         return view
    }()
    
    let fourthView: UIButton = {
        let view = UIButton(type: .system)
        view.addTarget(self, action: #selector(dismissView4), for: .touchUpInside)
        
         return view
     }()
    
    let fifthView: UIButton = {
           let view = UIButton(type: .system)
           view.addTarget(self, action: #selector(dismissView5), for: .touchUpInside)
           
            return view
        }()
    
    let sixthView: UIButton = {
              let view = UIButton(type: .system)
              view.addTarget(self, action: #selector(dismissFinal), for: .touchUpInside)
            return view
           }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstView.setImage(firstImage?.withRenderingMode(.alwaysOriginal), for: .normal)
       // secondView.setImage(secondImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        thirdView.setImage(thirdImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        fourthView.setImage(fourthImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        fifthView.setImage(fifthImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        sixthView.setImage(sixthImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        view.addSubview(sixthView)
        sixthView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        view.addSubview(fifthView)
        fifthView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        view.addSubview(fourthView)
        fourthView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        view.addSubview(thirdView)
        thirdView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
//        view.addSubview(secondView)
//        secondView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        view.addSubview(firstView)
        firstView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)

    }
    
    @objc fileprivate func dismissView1() {
        firstView.removeFromSuperview()
    }
//    @objc fileprivate func dismissView2() {
//        secondView.removeFromSuperview()
//    }
    @objc fileprivate func dismissView3() {
        thirdView.removeFromSuperview()
    }
    @objc fileprivate func dismissView4() {
        fourthView.removeFromSuperview()
    }
    @objc fileprivate func dismissView5() {
        fifthView.removeFromSuperview()
    }
    
    @objc fileprivate func dismissFinal() {
          sixthView.removeFromSuperview()
        let customtabController = CustomTabBarController()
        customtabController.modalPresentationStyle = .fullScreen
        self.present(customtabController, animated: true)
      }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
