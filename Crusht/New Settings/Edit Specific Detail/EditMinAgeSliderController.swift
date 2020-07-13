//
//  EditMinAgeSliderController.swift
//  Crusht
//
//  Created by William Kelly on 6/30/20.
//  Copyright © 2020 William Kelly. All rights reserved.
//

import UIKit
import Firebase

private class AgeRangeLabel: UILabel {
    override var intrinsicContentSize: CGSize {
        return .init(width: 100, height: 0)
    }
}

class EditMinAgeSliderController: UIViewController {
    
    var user: User?
    var delegate: SettingsControllerDelegate?
    var madeChange = false
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Location Match Age Range"
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
                      

        let overallStackView = UIStackView(arrangedSubviews: [
           // UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 30)),
            UIStackView(arrangedSubviews: [minLabel, minSlider]),
            UIStackView(arrangedSubviews: [maxLabel, maxSlider]),
            ])
        overallStackView.axis = .vertical
        overallStackView.spacing = 10
        view.addSubview(overallStackView)
        overallStackView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: view.bounds.height/5, left: 12, bottom: 0, right: 12))
        setup(minSeekingAge: user?.minSeekingAge, maxSeekingAge: user?.maxSeekingAge)
        
         minSlider.addTarget(self, action: #selector(handleMinChanged), for: .valueChanged)
         maxSlider.addTarget(self, action: #selector(handleMaxChanged), for: .valueChanged)
        
    }
    
        func setup(minSeekingAge: Int?, maxSeekingAge: Int?) {
            minLabel.text = " Min Age: \(minSeekingAge ?? 18)"
            maxLabel.text = " Max Age: \(maxSeekingAge ?? 50)"
            minSlider.value = Float(minSeekingAge ?? 18)
            maxSlider.value = Float(maxSeekingAge ?? 50)
//            view.layer.cornerRadius = 22
//            view.layer.masksToBounds = true
//          v  selectionStyle = .none
        }
        
        func evaluateMax() -> Int {
            let minValue = Int(minSlider.value)
            var maxValue = Int(maxSlider.value)
            maxValue = max(minValue, maxValue)
            maxSlider.value = Float(maxValue)
            maxLabel.text = " Max Age \(maxValue)"
            return maxValue
        }
        
        func evaluateMin() -> Int {
            let minValue = Int(minSlider.value)
            minLabel.text = " Min Age \(minValue)"
            return minValue
        }
        
        // MARK: - User Interface
        
        let minSlider: UISlider = {
            let slider = UISlider()
            slider.tintColor = #colorLiteral(red: 1, green: 0, blue: 0.6713966727, alpha: 1)
            slider.minimumValue = 18
            slider.maximumValue = 99
            return slider
        }()
        
        let maxSlider: UISlider = {
            let slider = UISlider()
            slider.tintColor = #colorLiteral(red: 1, green: 0, blue: 0.6713966727, alpha: 1)
            slider.minimumValue = 18
            slider.maximumValue = 99
            //slider.trackRect(forBounds: CGRect(origin: slider.bounds.origin, size: CGSize(width: slider.bounds.size.width, height: 10.0)))
            return slider
        }()
        
        let minLabel: UILabel = {
            let label = AgeRangeLabel()
            label.text = "Min: 18"
            label.font = UIFont.systemFont(ofSize: 16)
            return label
        }()
        
        let maxLabel: UILabel = {
            let label = AgeRangeLabel()
            label.text = "Max: 18"
             label.font = UIFont.systemFont(ofSize: 16)
            return label
        }()
    
    @objc fileprivate func handleBack() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let docData: [String: Any] = ["minSeekingAge": user?.minSeekingAge ?? "",
                                      "maxSeekingAge": user?.maxSeekingAge ?? ""]
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
            let minValue = self.evaluateMin()
            let maxValue = self.evaluateMax()
            user?.minSeekingAge = minValue
            user?.maxSeekingAge = maxValue
        }
        
    }


