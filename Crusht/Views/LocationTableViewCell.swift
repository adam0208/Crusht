//
//  LocationTableViewCell.swift
//  Crusht
//
//  Created by William Kelly on 12/11/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {
    
    let minSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        slider.minimumValue = 1
        slider.maximumValue = 99
        return slider
    }()
    
    let maxSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = #colorLiteral(red: 1, green: 0.6745098039, blue: 0.7215686275, alpha: 1)
        slider.minimumValue = 1
        slider.maximumValue = 99
        return slider
    }()
    
    let minLabel: UILabel = {
        let label = LocationRangeLabel()
        label.text = "Min: 18"
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let maxLabel: UILabel = {
        let label = LocationRangeLabel()
        label.text = "Max: 18"
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    class LocationRangeLabel: UILabel {
        override var intrinsicContentSize: CGSize {
            return .init(width: 100, height: 0)
        }
    }
    
    func evaluateMaxDistance() -> Int {
        var maxValue = Int(maxSlider.value)
        maxValue = max(maxValue, 1)
        maxSlider.value = Float(maxValue)
        maxLabel.text = " Miles \(maxValue)"
        return maxValue
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let overallStackView = UIStackView(arrangedSubviews: [
            UIView(),
            UIStackView(arrangedSubviews: [maxLabel, maxSlider]),
            ])
        overallStackView.axis = .vertical
        overallStackView.spacing = 5
        addSubview(overallStackView)
        overallStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 16, left: 16, bottom: 16, right: 16))
        overallStackView.fillSuperview()
        
    }
    
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
    
    func setup(maxDistance: Int?) {
        // minLabel.text = " Min Km: \(user?.minDistance ?? 1)"
        // minSlider.value = Float(user?.minDistance ?? 1)
        maxLabel.text = " Miles: \(maxDistance ?? 50)"
        maxSlider.value = Float(maxDistance ?? 50)
        layer.cornerRadius = 16
        layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
