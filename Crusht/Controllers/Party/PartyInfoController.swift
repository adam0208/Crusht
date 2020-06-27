//
//  PartyInfoController.swift
//  Crusht
//
//  Created by William Kelly on 6/26/20.
//  Copyright © 2020 William Kelly. All rights reserved.
//

import UIKit

class PartyInfoController: UIViewController {

        var user: User?
        var party: Party?
        
        //UI
        
        let partyLocationLabel: UILabel = {
           let label = UILabel()
            label.backgroundColor = .clear
            label.textColor = .black
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
            label.adjustsFontSizeToFitWidth = true
            return label
        }()
    
        let partyDetailsLabel: UILabel = {
           let label = UILabel()
            label.backgroundColor = .clear
            label.textColor = .black
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
            label.adjustsFontSizeToFitWidth = false
            label.numberOfLines = 0
            return label
        }()
    
    let partyStartTimeLabel: UILabel = {
           let label = UILabel()
            label.backgroundColor = .clear
            label.textColor = .black
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        label.adjustsFontSizeToFitWidth = true

            return label
        }()
    
    let partyEndTimeLabel: UILabel = {
            let label = UILabel()
             label.backgroundColor = .clear
             label.textColor = .black
             label.textAlignment = .center
             label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        label.adjustsFontSizeToFitWidth = true

             return label
         }()
        
        let underline: UIView = {
            let view = UIView()
            view.heightAnchor.constraint(equalToConstant: 4).isActive = true
            view.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.6705882353, alpha: 1)
            return view
        }()
        
        let underline2: UIView = {
              let view = UIView()
              view.heightAnchor.constraint(equalToConstant: 4).isActive = true
              view.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.6713966727, alpha: 1)
              return view
          }()
    
    let underline3: UIView = {
             let view = UIView()
             view.heightAnchor.constraint(equalToConstant: 4).isActive = true
             view.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.6713966727, alpha: 1)
             return view
         }()
    
    let underline4: UIView = {
             let view = UIView()
             view.heightAnchor.constraint(equalToConstant: 4).isActive = true
             view.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.6713966727, alpha: 1)
             return view
         }()
    
    let underline5: UIView = {
             let view = UIView()
             view.heightAnchor.constraint(equalToConstant: 4).isActive = true
             view.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.6713966727, alpha: 1)
             return view
         }()
        
        private let label: UILabel = {
            let label = UILabel()
            label.text = "Party Page"
            label.textColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
            label.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            
            return label
        }()
        
        private let addToCalenderButton: UIButton = {
               let button = UIButton(type: .system)
               button.setTitle("Add To Calendar", for: .normal)
               button.setTitleColor(.white, for: .normal)
               button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
               button.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
               button.heightAnchor.constraint(equalToConstant: 44).isActive = true
               button.widthAnchor.constraint(equalToConstant: 60).isActive = true
               button.titleLabel?.adjustsFontForContentSizeCategory = true
               button.layer.cornerRadius = 18
               //button.addTarget(self, action: #selector(handleDone), for: .touchUpInside)
               
               return button
           }()

        let backButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "icons8-chevron-left-30").withRenderingMode(.alwaysOriginal), for: .normal)
            button.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
            return button
        }()
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.navigationController?.navigationBar.isHidden = true
        }
     

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .white
            
            label.text = party?.partyName
           
            partyDetailsLabel.text = party?.partyDetails
            partyLocationLabel.text = party?.partyLocation
            partyStartTimeLabel.text = "\(party?.startTime)"
            
            partyEndTimeLabel.text = "\(party?.endTime)"
      
            view.addSubview(label)
            label.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                leading: view.leadingAnchor,
                                bottom: nil,
                                trailing: view.trailingAnchor,
                                padding: .init(top: 12, left: 30, bottom: 0, right: 30))
            
            view.addSubview(backButton)
            backButton.anchor(top: label.topAnchor, leading: view.leadingAnchor, bottom: label.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 6, bottom: 0, right: 0))
                   
                 view.addSubview(partyDetailsLabel)
            partyDetailsLabel.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: view.bounds.height/5, left: 30, bottom: 0, right: 30))
                 
                 view.addSubview(underline)
            underline.anchor(top: partyDetailsLabel.bottomAnchor, leading: partyDetailsLabel.leadingAnchor, bottom: nil, trailing: partyDetailsLabel.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
            
            view.addSubview(partyLocationLabel)
            partyLocationLabel.anchor(top: underline.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 12, left: 30, bottom: 0, right: 30))
                        
                        view.addSubview(underline2)
            underline2.anchor(top: partyLocationLabel.bottomAnchor, leading: partyLocationLabel.leadingAnchor, bottom: nil, trailing: partyLocationLabel.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
            
            let stack = UIStackView(arrangedSubviews: [partyStartTimeLabel, partyEndTimeLabel])
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            stack.spacing = 8
            view.addSubview(stack)
            stack.anchor(top: underline2.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 12, left: 30, bottom: 0, right: 30))
            
            view.addSubview(underline3)
            underline3.anchor(top: partyStartTimeLabel.bottomAnchor, leading: partyStartTimeLabel.leadingAnchor, bottom: nil, trailing: partyStartTimeLabel.trailingAnchor)
            
            view.addSubview(underline4)
            underline4.anchor(top: partyEndTimeLabel.bottomAnchor, leading: partyEndTimeLabel.leadingAnchor, bottom: nil, trailing: partyEndTimeLabel.trailingAnchor)
            
            view.addSubview(addToCalenderButton)
            addToCalenderButton.anchor(top: underline4.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 20, left: 50 , bottom: 0, right: 50))
            
        }
        
        //Functions
        
        @objc fileprivate func handleBack() {
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.popViewController(animated: true)
        }

}
