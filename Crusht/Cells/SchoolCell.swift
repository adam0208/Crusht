//
//  SchoolCell.swift
//  Crusht
//
//  Created by Santiago Goycoechea on 10/21/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit

private class SchoolCellTF: UITextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0)
    }
    
    override var intrinsicContentSize: CGSize {
        return .init(width: 0, height: 50)
    }
}

class SchoolCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    let myPickerData = Constants.universityList
    var settings = EditProfileController()
    var schoolChange = String()
    var schoolPicker = UIPickerView()
    
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
        schoolPicker.delegate = self
        addSubview(textField)
        textField.inputView = schoolPicker
        textField.fillSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(school: String?) {
        textField.placeholder = "School"
        textField.text = school
        layer.cornerRadius = 16
        layer.masksToBounds = true
    }
    
    let textField: UITextField = {
        let tf = SchoolCellTF()
        return tf
    }()
    
    // MARK: - UIPickerViewDelegate, UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myPickerData.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return myPickerData[row]
    }

    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField.text = myPickerData[row]
        schoolChange = myPickerData[row]
        settings.user?.school = myPickerData[row]
    }
}
