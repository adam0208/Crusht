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
        let label = LocationRangeLabel()
        label.text = "Min: 18"
        return label
    }()
    
    let maxLabel: UILabel = {
        let label = LocationRangeLabel()
        label.text = "Max: 18"
        return label
    }()
    
    class LocationRangeLabel: UILabel {
        override var intrinsicContentSize: CGSize {
            return .init(width: 80, height: 0)
        }
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let overallStackView = UIStackView(arrangedSubviews: [
            UIStackView(arrangedSubviews: [minLabel, minSlider]),
            UIStackView(arrangedSubviews: [maxLabel, maxSlider]),
            ])
        overallStackView.axis = .vertical
        overallStackView.spacing = 16
        addSubview(overallStackView)
        overallStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 16, left: 16, bottom: 16, right: 16))
        overallStackView.fillSuperview()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
