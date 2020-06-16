//
//  EditSchoolController.swift
//  Crusht
//
//  Created by William Kelly on 6/13/20.
//  Copyright © 2020 William Kelly. All rights reserved.
//

import UIKit
import Firebase

class EditSchoolController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UISearchBarDelegate {

       //NEED TO ADD A DID SAVE SETTINGS DELAGATE TO THESE
    
       var user: User?
    
    
        let myPickerData = Constants.universityList
        var filteredPickerData = [String]()
        var filtering = false
        var selectNextSchool = false
        
        //UI
        
        let schoolTF: UITextField = {
            let tf = UITextField()
            tf.backgroundColor = .clear
            tf.textColor = .black
            tf.textAlignment = .left
            tf.font = UIFont.systemFont(ofSize: 40, weight: .bold)
            return tf
        }()
        
        let underline: UIView = {
            let view = UIView()
            view.heightAnchor.constraint(equalToConstant: 4).isActive = true
            view.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0.6713966727, alpha: 1)
            return view
        }()
        
        private let label: UILabel = {
            let label = UILabel()
            label.text = "Your School"
            label.textColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
            label.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            
            return label
        }()
        
        private let errorLabel: UILabel = {
            let label = UILabel()
            label.text = "Please enter your school"
            label.textColor = .black
            label.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            
            return label
        }()
        
        private let saveButton: UIButton = {
               let button = UIButton(type: .system)
               button.setTitle("Save", for: .normal)
               button.setTitleColor(.white, for: .normal)
               button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
               button.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
               button.heightAnchor.constraint(equalToConstant: 44).isActive = true
               button.widthAnchor.constraint(equalToConstant: 60).isActive = true
               button.titleLabel?.adjustsFontForContentSizeCategory = true
               button.layer.cornerRadius = 18
               button.addTarget(self, action: #selector(handleDone), for: .touchUpInside)
               
               return button
           }()
    
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.searchTextField.textColor = .black
        sb.searchTextField.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        sb.searchTextField.adjustsFontSizeToFitWidth = true
        sb.searchTextField.textAlignment = .left
        sb.searchTextField.backgroundColor = .clear
        sb.backgroundColor = .white
        
        sb.backgroundImage = UIImage()
        //sb.searchTextField.backgroundColor = .white
       // sb.setImage(UIImage(), for: .search, state: .normal)
        return sb
    }()
    
    private let schoolPicker: UIPickerView = {
        let sp = UIPickerView()
        sp.backgroundColor = .white
        
        return sp
    }()
        
        let backButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "icons8-chevron-left-30").withRenderingMode(.alwaysOriginal), for: .normal)
            button.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
            return button
        }()
    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        for subView in searchBar.subviews  {
//                            for subsubView in subView.subviews  {
//                                if let textField = subsubView as? UITextField {
//                                     var bounds: CGRect
//                                bounds = textField.bounds
//                                bounds.size.height = 100 //(set height whatever you want)
//                                    textField.bounds = bounds
//
//                //                    textField.font = UIFont.systemFontOfSize(20)
//                                }
//                            }
//                        }
//    }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.navigationController?.navigationBar.isHidden = true

        }
    
     

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .white
            
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).clearButtonMode = .never
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).leftViewMode = .never
      
            schoolPicker.delegate = self
            searchBar.delegate = self
            searchBar.text = user?.school ?? ""
                        
//            schoolTF.inputView = schoolPicker
//
//            schoolTF.text = user?.school ?? ""
//
            view.addSubview(label)
            label.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                leading: view.leadingAnchor,
                                bottom: nil,
                                trailing: view.trailingAnchor,
                                padding: .init(top: 12, left: 30, bottom: 0, right: 30))
            
            view.addSubview(backButton)
            backButton.anchor(top: label.topAnchor, leading: view.leadingAnchor, bottom: label.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 6, bottom: 0, right: 0))
                   
                 view.addSubview(searchBar)
            searchBar.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: view.bounds.height/5, left: -50, bottom: 0, right: 30))
                 
                 view.addSubview(underline)
            underline.anchor(top: searchBar.bottomAnchor, leading: searchBar.leadingAnchor, bottom: nil, trailing: searchBar.trailingAnchor, padding: .init(top: 0, left: 70, bottom: 0, right: 0))
            
                 view.addSubview(saveButton)
            saveButton.anchor(top: underline.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 20, left: 120, bottom: 0, right: 120))
            
//            view.addSubview(searchBar)
//                     searchBar.anchor(top: saveButton.bottomAnchor,
//                                      leading: view.leadingAnchor,
//                                      bottom: nil,
//                                      trailing: view.trailingAnchor,
//                                      padding: .init(top: 10, left: 0, bottom: 0, right: 0))
            
            view.addSubview(schoolPicker)
            schoolPicker.isHidden = true
            schoolPicker.anchor(top: saveButton.bottomAnchor,
                                leading: view.leadingAnchor,
                                bottom: nil,
                                trailing: view.trailingAnchor,
                                padding: .init(top: 0, left: 0, bottom: 10, right: 0))
//                   view.addSubview(errorLabel)
//                   errorLabel.isHidden = true
//                   errorLabel.anchor(top: saveButton.bottomAnchor,
//                                     leading: view.leadingAnchor,
//                                     bottom: nil,
//                                     trailing: view.trailingAnchor,
//                                     padding: .init(top: 40, left: 20, bottom: 0, right: 20))
            // Do any additional setup after loading the view.
        }
        
        //Functions

        @objc fileprivate func handleDone() {
          
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let docData: [String: Any] = ["School": searchBar.searchTextField.text ?? ""]
            Firestore.firestore().collection("users").document(uid).setData(docData, merge: true)
            self.handleBack()
        }
        
        @objc fileprivate func handleBack() {
            self.navigationController?.navigationBar.isHidden = false
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.popViewController(animated: true)
        }
    
    // MARK: - UIPickerViewDelegate, UIPickerViewDataSource
      
      func numberOfComponents(in pickerView: UIPickerView) -> Int {
          return 1
      }
      
      func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
          return filtering ? filteredPickerData.count : myPickerData.count
      }
      
      func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
          if selectNextSchool {
              selectNextSchool = false
//            searchBar.searchTextField.text = filtering ? filteredPickerData[pickerView.selectedRow(inComponent: 0)] : myPickerData[pickerView.selectedRow(inComponent: 0)]
          }
          return filtering ? filteredPickerData[row] : myPickerData[row]
      }
      
      func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
          if filtering {
            searchBar.searchTextField.text = filteredPickerData.count > 0 ? filteredPickerData[row] : ""
          } else {
            searchBar.searchTextField.text = myPickerData[row]
          }
      }
    
       // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
          if searchText != "" {
              filteredPickerData = myPickerData.filter { (school: String) -> Bool in
                schoolPicker.isHidden = false
                return school.lowercased().contains(searchText.lowercased())
                
              }
//             if myPickerData.contains(searchText) == false  {
//                schoolPicker.isHidden = true
//            }
              filtering = true
              schoolPicker.reloadAllComponents()
          } else {
            
              filtering = false
              schoolPicker.reloadAllComponents()
          }
          selectNextSchool = true
      }
      
    }
