//
//  EditMaxDistanceController.swift
//  Crusht
//
//  Created by William Kelly on 7/13/20.
//  Copyright © 2020 William Kelly. All rights reserved.
//

import UIKit
import Firebase

private class LocationRangeLabel: UILabel {
    override var intrinsicContentSize: CGSize {
        return .init(width: 100, height: 0)
    }
}

class EditMaxDistanceController: UIViewController {
      var user: User?
        var delegate: SettingsControllerDelegate?
        var madeChange = false
        
        private let label: UILabel = {
            let label = UILabel()
            label.text = "Location Match Max Distance"
            label.textColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
            label.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            
            return label
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
            
            view.addSubview(label)
                   label.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                       leading: view.leadingAnchor,
                                       bottom: nil,
                                       trailing: view.trailingAnchor,
                                       padding: .init(top: 12, left: 30, bottom: 0, right: 30))
                   
                   view.addSubview(backButton)
                   backButton.anchor(top: label.topAnchor, leading: view.leadingAnchor, bottom: label.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 6, bottom: 0, right: 0))
                          

            let stack = UIStackView(arrangedSubviews: [maxLabel, maxSlider])
            stack.axis = .horizontal
            stack.spacing = 2
            stack.distribution = .fill
            view.addSubview(stack)
            stack.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: view.bounds.height/5, left: 12, bottom: 0, right: 12))
            setup(maxDistance: user?.maxDistance)
            
             maxSlider.addTarget(self, action: #selector(handleMaxChanged), for: .valueChanged)
            
        }
        
            func setup(maxDistance: Int?) {
                maxLabel.text = " Miles: \(maxDistance ?? 1)"
                maxSlider.value = Float(maxDistance ?? 1)
    //            view.layer.cornerRadius = 22
    //            view.layer.masksToBounds = true
    //          v  selectionStyle = .none
            }
            
            func evaluateMaxDistance() -> Int {
                var maxValue = Int(maxSlider.value)
                maxValue = max(maxValue, 1)
                maxSlider.value = Float(maxValue)
                maxLabel.text = " Miles \(maxValue)"
                return maxValue
            }
            
            // MARK: - User Interface
            
            let maxSlider: UISlider = {
                let slider = UISlider()
                slider.tintColor = #colorLiteral(red: 1, green: 0, blue: 0.6713966727, alpha: 1)
                slider.minimumValue = 1
                slider.maximumValue = 50
                return slider
            }()
            
            let maxLabel: UILabel = {
                let label = LocationRangeLabel()
                label.text = "Min: 1"
                label.font = UIFont.systemFont(ofSize: 16)
                return label
            }()
 
        
        @objc fileprivate func handleBack() {
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let docData: [String: Any] = ["maxDistance": user?.maxDistance ?? ""]
                                          
            Firestore.firestore().collection("users").document(uid).setData(docData, merge: true)
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.navigationBar.prefersLargeTitles = true
             self.navigationController?.popViewController(animated: true) {
            self.madeChange = true
                           if self.madeChange == true {
                       self.delegate?.didSaveSettings()
                       }
            }
            
        }
        
            @objc fileprivate func handleMinChanged (slider: UISlider) {
                evaluateMinMax()
            }
        
            @objc fileprivate func handleMaxChanged (slider: UISlider) {
                evaluateMinMax()
            }
        
            fileprivate func evaluateMinMax() {
                let maxValue = self.evaluateMaxDistance()
                user?.maxDistance = maxValue
            }
            
        }


