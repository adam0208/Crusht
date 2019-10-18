//
//  SettingsCells.swift
//  Crusht
//
//  Created by William Kelly on 12/8/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit



class SettingsCells: UITableViewCell {
    
    class SettingsTextField: UITextField {
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
    
    let textField: UITextField = {
        let tf = SettingsTextField()
        tf.placeholder = "Enter Name"
        //tf.isscro = false
        return tf
    } ()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(textField)
//        layoutMargins = UIEdgeInsets.zero // remove table cell separator margin
//        contentView.layoutMargins.left = 20 // set up left margin to 20
//        contentView.layoutMargins.right = 20
//        contentView.backgroundColor = .clear
//        backgroundColor = .white
        textField.fillSuperview()
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

class GenderCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    class GenderTextField: UITextField {
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
    
    var settings = SettingsTableViewController()
    
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
        genderSwitch = myPickerData[row]
        settings.user?.gender = myPickerData[row]
        
    }
    
    
    var genderPicker = UIPickerView()
    
    let myPickerData = [String](arrayLiteral: "Male", "Female", "Other")
    
    let textField: UITextField = {
        let tf = GenderTextField()
        //tf.isscro = false
        return tf
    } ()
    
    var genderSwitch = String()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        genderPicker.delegate = self
        textField.inputView = genderPicker
        addSubview(textField)
        //        layoutMargins = UIEdgeInsets.zero // remove table cell separator margin
        //        contentView.layoutMargins.left = 20 // set up left margin to 20
        //        contentView.layoutMargins.right = 20
        //        contentView.backgroundColor = .clear
        //        backgroundColor = .white
        
        textField.fillSuperview()
    }
    @objc func cancelPicker(){
        self.endEditing(true)
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

class GenderPrefCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
    class GenderPrefTextField: UITextField {
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
    
      var settings = SettingsTableViewController()
    
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
        
        sexPrefSwitch = myPickerData[row]
        settings.user?.sexPref = myPickerData[row]
        
    }
    
    var genderPrefPicker = UIPickerView()
    var sexPrefSwitch = String()
    
    let myPickerData = [String](arrayLiteral: "Male", "Female", "All Humans")
    
    let textField: UITextField = {
        let tf = GenderPrefTextField()
        //tf.isscro = false
        return tf
    } ()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        genderPrefPicker.delegate = self
        addSubview(textField)
        textField.inputView = genderPrefPicker
        genderPrefPicker.dataSource = self
        //        layoutMargins = UIEdgeInsets.zero // remove table cell separator margin
        //        contentView.layoutMargins.left = 20 // set up left margin to 20
        //        contentView.layoutMargins.right = 20
        //        contentView.backgroundColor = .clear
        //        backgroundColor = .white
        textField.fillSuperview()
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

class SchoolCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    class SchoolCellTF: UITextField {
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
    
      var settings = SettingsTableViewController()
        
    let textField: UITextField = {
        let tf = SchoolCellTF()
        //tf.isscro = false
        return tf
    } ()
    
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
    
  
    var schoolChange = String()
    var schoolPicker = UIPickerView()
    
    let myPickerData = Constants.universityList
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        schoolPicker.delegate = self
        addSubview(textField)
        textField.inputView = schoolPicker
        
       
        textField.fillSuperview()
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

