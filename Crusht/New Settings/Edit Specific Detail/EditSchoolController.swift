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
        var madeChange = false
        var delegate: SettingsControllerDelegate?
        let myPickerData = Constants.universityList
        var filteredPickerData = [String]()
        var filtering = false
        var selectNextSchool = false

            // MARK: - Life Cycle Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

            override func viewDidLoad() {
                super.viewDidLoad()
                schoolPicker.delegate = self
                searchBar.delegate = self
                initializeUI()
            }

            // MARK: - Logic

            @objc private func handleDone() {
                guard let school = schoolTF.text, school != "" else {
                    errorLabel.isHidden = false
                    return
                }
              

                guard let uid = Auth.auth().currentUser?.uid else {return}
                let docData: [String: Any] = ["School": schoolTF.text ?? ""]
                Firestore.firestore().collection("users").document(uid).setData(docData, merge: true)
                madeChange = true
                self.handleBack()
            }
    
    @objc fileprivate func handleBack() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
         self.navigationController?.popViewController(animated: true) {
                       if self.madeChange == true {
                   self.delegate?.didSaveSettings()
            }
        }
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
                    schoolTF.text = filtering ? filteredPickerData[pickerView.selectedRow(inComponent: 0)] : myPickerData[pickerView.selectedRow(inComponent: 0)]
                }
                return filtering ? filteredPickerData[row] : myPickerData[row]
            }

            func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
                if filtering {
                    schoolTF.text = filteredPickerData.count > 0 ? filteredPickerData[row] : ""
                } else {
                    schoolTF.text = myPickerData[row]
                }
            }

            // MARK: - UISearchBarDelegate

            func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
                if searchText != "" {
                    filteredPickerData = myPickerData.filter { (school: String) -> Bool in
                        school.lowercased().contains(searchText.lowercased())
                    }
                    filtering = true
                    schoolPicker.reloadAllComponents()
                } else {
                    filtering = false
                    schoolPicker.reloadAllComponents()
                }
                selectNextSchool = true
            }

            // MARK: - User Interface

            private func initializeUI() {
                view.backgroundColor = .white
                schoolTF.text = user?.school ?? ""

                view.addSubview(label)
                label.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                        leading: view.leadingAnchor,
                        bottom: nil,
                        trailing: view.trailingAnchor,
                        padding: .init(top: 12, left: 30, bottom: 0, right: 30))
                
                view.addSubview(backButton)
                backButton.anchor(top: label.topAnchor, leading: view.leadingAnchor, bottom: label.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 6, bottom: 0, right: 0))

                view.addSubview(schoolTF)
                schoolTF.anchor(top: label.bottomAnchor,
                                leading: view.leadingAnchor,
                                bottom: nil,
                                trailing: view.trailingAnchor,
                                padding: .init(top: 0, left: 10, bottom: 0, right: 10))
                
                view.addSubview(searchBar)
                searchBar.anchor(top: schoolTF.bottomAnchor,
                                 leading: view.leadingAnchor,
                                 bottom: nil,
                                 trailing: view.trailingAnchor,
                                 padding: .init(top: 10, left: 0, bottom: 0, right: 0))

                view.addSubview(errorLabel)
                errorLabel.isHidden = true
                errorLabel.anchor(top: nil,
                                  leading: view.leadingAnchor,
                                  bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                  trailing: view.trailingAnchor,
                                  padding: .init(top: 0, left: 20, bottom: view.bounds.height / 3, right: 20))

                view.addSubview(doneButton)
                doneButton.anchor(top: nil,
                                  leading: view.leadingAnchor,
                                  bottom: errorLabel.topAnchor,
                                  trailing: view.trailingAnchor,
                                  padding: .init(top: 0, left: 30, bottom: 5, right: 30))

                view.addSubview(schoolPicker)
                schoolPicker.anchor(top: searchBar.bottomAnchor,
                                    leading: view.leadingAnchor,
                                    bottom: doneButton.topAnchor,
                                    trailing: view.trailingAnchor,
                                    padding: .init(top: 0, left: 0, bottom: 10, right: 0))
            }

            private let schoolTF: UITextField = {
                let tf = NameTextField()
                tf.placeholder = "School"
                tf.backgroundColor = .white
                tf.layer.cornerRadius = 15
                tf.textAlignment = .center
                tf.font = UIFont.systemFont(ofSize: 25)
                tf.heightAnchor.constraint(equalToConstant: 60).isActive = true
                tf.isUserInteractionEnabled = false
                return tf
            }()

            private let searchBar: UISearchBar = {
                let sb = UISearchBar()
                sb.heightAnchor.constraint(equalToConstant: 60).isActive = true
                return sb
            }()

            private let schoolPicker: UIPickerView = {
                let sp = UIPickerView()
                sp.backgroundColor = .white
                return sp
            }()

            private let label: UILabel = {
                let label = UILabel()
                label.text = "Select Your School/Alma Mater"
                label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
                label.heightAnchor.constraint(equalToConstant: 100).isActive = true
                label.textAlignment = .center
                label.adjustsFontSizeToFitWidth = true
                label.numberOfLines = 0
                label.textColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)

                return label
            }()

            private let errorLabel: UILabel = {
                let label = UILabel()
                label.text = "Please select your school/alma mater"
                label.textColor = .black
                label.heightAnchor.constraint(equalToConstant: 40).isActive = true
                label.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
                label.textAlignment = .center
                label.adjustsFontSizeToFitWidth = true

                return label
            }()

            private let doneButton: UIButton = {
                let button = UIButton(type: .system)
                button.setTitle("Next", for: .normal)
                button.setTitleColor(.white, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
                button.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
                button.heightAnchor.constraint(equalToConstant: 60).isActive = true
                button.widthAnchor.constraint(equalToConstant: 60).isActive = true
                button.translatesAutoresizingMaskIntoConstraints = false
                button.titleLabel?.adjustsFontForContentSizeCategory = true
                button.layer.cornerRadius = 22
                button.addTarget(self, action: #selector(handleDone), for: .touchUpInside)

                return button
            }()
    
    let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "icons8-chevron-left-30").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        return button
    }()

        }
