//
//  VenueDistanceCell.swift
//  Crusht
//
//  Created by William Kelly on 6/20/20.
//  Copyright © 2020 William Kelly. All rights reserved.
//

import UIKit

private class VenueDistanceLabel: UILabel {
    override var intrinsicContentSize: CGSize {
        return .init(width: 100, height: 0)
    }
}

class VenueDistanceCell: UITableViewCell {
        override var frame: CGRect {
            get {
                return super.frame
            }
            set (newFrame) {
                var frame = newFrame
                frame.origin.x += 10
                frame.size.width -= 2 * 12
                super.frame = frame
            }
        }
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            let overallStackView = UIStackView(arrangedSubviews: [
                UIStackView(arrangedSubviews: [maxLabel, maxSlider]),
                ])
            overallStackView.axis = .vertical
            overallStackView.spacing = 5
            addSubview(overallStackView)
            overallStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 16, left: 16, bottom: 16, right: 16))
            overallStackView.fillSuperview()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Logic
        
        func setup(maxDistance: Int?) {
            // minLabel.text = " Min Km: \(user?.minDistance ?? 1)"
            // minSlider.value = Float(user?.minDistance ?? 1)
            maxLabel.text = " Miles: \(maxDistance ?? 50)"
            maxSlider.value = Float(maxDistance ?? 50)
            layer.cornerRadius = 16
            layer.masksToBounds = true
            selectionStyle = .none
        }
        
        func evaluateMaxDistance() -> Int {
            var maxValue = Int(maxSlider.value)
            maxValue = max(maxValue, 1)
            maxSlider.value = Float(maxValue)
            maxLabel.text = " Miles \(maxValue)"
            return maxValue
        }
        
        // MARK: - User Interface
        
        let minSlider: UISlider = {
            let slider = UISlider()
            slider.tintColor = #colorLiteral(red: 1, green: 0, blue: 0.6713966727, alpha: 1)
            slider.minimumValue = 1
            slider.maximumValue = 99
            return slider
        }()
        
        let maxSlider: UISlider = {
            let slider = UISlider()
            slider.tintColor = #colorLiteral(red: 1, green: 0, blue: 0.6713966727, alpha: 1)
            slider.minimumValue = 1
            slider.maximumValue = 99
            return slider
        }()
        
        let minLabel: UILabel = {
            let label = VenueDistanceLabel()
            label.text = "Min: 18"
            label.font = UIFont.systemFont(ofSize: 15)
            return label
        }()
        
        let maxLabel: UILabel = {
            let label = VenueDistanceLabel()
            label.text = "Max: 18"
            label.font = UIFont.systemFont(ofSize: 15)
            return label
        }()
    }
