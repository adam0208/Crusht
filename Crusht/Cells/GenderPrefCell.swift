//
//  GenderPrefCell.swift
//  Crusht
//
//  Created by Santiago Goycoechea on 10/21/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

//import UIKit
//
//private class GenderPrefCellTextField: UITextField {
//    override func textRect(forBounds bounds: CGRect) -> CGRect {
//        return bounds.insetBy(dx: 10, dy: 0)
//    }
//
//    override func editingRect(forBounds bounds: CGRect) -> CGRect {
//        return bounds.insetBy(dx: 10, dy: 0)
//    }
//
//    override var intrinsicContentSize: CGSize {
//        return .init(width: 0, height: 50)
//    }
//}
//
//class GenderPrefCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
//    let myPickerData = [String](arrayLiteral: "Male", "Female", "All Humans")
//    var genderPrefPicker = UIPickerView()
//    var sexPrefSwitch = String()
//
//    override var frame: CGRect {
//        get {
//            return super.frame
//        }
//        set (newFrame) {
//            var frame = newFrame
//            frame.origin.x += 10
//            frame.size.width -= 2 * 12
//            super.frame = frame
//        }
//    }
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        genderPrefPicker.delegate = self
//        addSubview(textField)
//        textField.inputView = genderPrefPicker
//        genderPrefPicker.dataSource = self
//        textField.fillSuperview()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func setup(sexPref: String?) {
//        textField.placeholder = "Sex Preference"
//        textField.text = sexPref
//        layer.cornerRadius = 16
//        layer.masksToBounds = true
//    }
//
//    let textField: UITextField = {
//        let tf = GenderPrefCellTextField()
//        return tf
//    }()
//
//    // MARK: - UIPickerViewDataSource, UIPickerViewDelegate
//
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return myPickerData.count
//    }
//
//    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return myPickerData[row]
//    }
//
//    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        textField.text = myPickerData[row]
//        sexPrefSwitch = myPickerData[row]
//        settings.user?.sexPref = myPickerData[row]
//    }
//}
