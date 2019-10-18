//
//  AgeRangeTableViewCell.swift
//  Crusht
//
//  Created by William Kelly on 12/9/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit

class AgeRangeTableViewCell: UITableViewCell {
    
    let minSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        slider.minimumValue = 18
        slider.maximumValue = 99
        return slider
    }()
    
    let maxSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = #colorLiteral(red: 1, green: 0.6745098039, blue: 0.7215686275, alpha: 1)
        slider.minimumValue = 18
        slider.maximumValue = 99
        return slider
    }()
    
    let minLabel: UILabel = {
        let label = AgeRangeLabel()
        label.text = "Min: 18"
         label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let maxLabel: UILabel = {
        let label = AgeRangeLabel()
        label.text = "Max: 18"
         label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    class AgeRangeLabel: UILabel {
        override var intrinsicContentSize: CGSize {
            return .init(width: 100, height: 0)
        }
    }
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let overallStackView = UIStackView(arrangedSubviews: [
            UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 6)),
            UIStackView(arrangedSubviews: [minLabel, minSlider]),
            UIStackView(arrangedSubviews: [maxLabel, maxSlider]),
            ])
        overallStackView.axis = .vertical
        overallStackView.spacing = 5
        addSubview(overallStackView)
        overallStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 20, left: 16, bottom: 16, right: 16))
        overallStackView.fillSuperview()
        
    }
    
    func setup(minSeekingAge: Int?, maxSeekingAge: Int?) {
        minLabel.text = " Min Age: \(minSeekingAge ?? 18)"
        maxLabel.text = " Max Age: \(maxSeekingAge ?? 50)"
        minSlider.value = Float(minSeekingAge ?? 18)
        maxSlider.value = Float(maxSeekingAge ?? 50)
        layer.cornerRadius = 22
        layer.masksToBounds = true
    }
    
    func evaluateMax() -> Int {
        let minValue = Int(minSlider.value)
        var maxValue = Int(maxSlider.value)
        maxValue = max(minValue, maxValue)
        maxSlider.value = Float(maxValue)
        maxLabel.text = "Max Age \(maxValue)"
        return maxValue
    }
    
    func evaluateMin() -> Int {
        let minValue = Int(minSlider.value)
        minLabel.text = "Min Age \(minValue)"
        return minValue
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
