//
//  SeniorFiveTableViewController.swift
//  Crusht
//
//  Created by William Kelly on 12/11/18.
//  Copyright © 2018 William Kelly. All rights reserved.
//

import UIKit


class CustomImagePickerController2: UIImagePickerController {
    
    var imageButton: UIButton?
    
}

class SeniorFiveTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        // instance properties
        lazy var image1Button = createButton(selector: #selector(handleSelectPhoto))
        lazy var image2Button = createButton(selector: #selector(handleSelectPhoto))
        lazy var image3Button = createButton(selector: #selector(handleSelectPhoto))
        
        @objc func handleSelectPhoto(button: UIButton) {
            print("Select photo with button:", button)
            let imagePicker = CustomImagePickerController2()
            imagePicker.delegate = self
            imagePicker.imageButton = button
            present(imagePicker, animated: true)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let selectedImage = info[.originalImage] as? UIImage
            // how do i set the image on my buttons when I select a photo?
            let imageButton = (picker as? CustomImagePickerController2)?.imageButton
            imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
            dismiss(animated: true)
        }
        
        func createButton(selector: Selector) -> UIButton {
            let button = UIButton(type: .system)
            button.setTitle("Select Photo", for: .normal)
            button.backgroundColor = .white
            button.layer.cornerRadius = 8
            button.addTarget(self, action: selector, for: .touchUpInside)
            button.imageView?.contentMode = .scaleAspectFill
            button.clipsToBounds = true
            return button
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            setupNavigationItems()
            tableView.backgroundColor = #colorLiteral(red: 0.7607843137, green: 0.9294117647, blue: 0.6784313725, alpha: 1)
            ///tableView.tableFooterView = UIView()
        }
   
    class HeaderLabel: UILabel {
        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.insetBy(dx: 16, dy: 0))
        }
    }
    
    
    lazy var header: UIView = {
        let header = UIView()
        header.addSubview(image1Button)
        let padding: CGFloat = 16
        image1Button.anchor(top: header.topAnchor, leading: header.leadingAnchor, bottom: header.bottomAnchor, trailing: nil, padding: .init(top: padding, left: padding, bottom: padding, right: 0))
        image1Button.widthAnchor.constraint(equalTo: header.widthAnchor, multiplier: 0.45).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [image2Button, image3Button])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = padding
        
        header.addSubview(stackView)
        stackView.anchor(top: header.topAnchor, leading: image1Button.trailingAnchor, bottom: header.bottomAnchor, trailing: header.trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        return header
    }()
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return header
        }
        let headerLabel = HeaderLabel()
        headerLabel.font = UIFont.boldSystemFont(ofSize: 16)
        headerLabel.text = "Date of Post"
        
        return headerLabel
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 10
    }
        
        override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 100
        }
    
        
        fileprivate func setupNavigationItems() {
            navigationItem.title = "Senior Five"
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Write Your 5", style: .plain, target: self, action: #selector(handleCancel))
        }
        
        @objc fileprivate func handleCancel() {
            dismiss(animated: true)
        }
        
}
