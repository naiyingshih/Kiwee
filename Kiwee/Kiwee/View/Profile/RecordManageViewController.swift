//
//  RecordManageViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/18.
//

import UIKit

class RecordManageViewController: UIViewController {
    
    var initialUserData: UserData?
    var updates: [String: Any] = [:]
    var selectedButton: UIButton?
    
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var goalWeightTextField: UITextField!
    @IBOutlet weak var goalSegment: UISegmentedControl!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var backView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.hexStringToUIColor(hex: "004358")
        backView.backgroundColor = UIColor.hexStringToUIColor(hex: "f8f7f2")
        backView.layer.cornerRadius = 20
        datePicker.tintColor = UIColor.hexStringToUIColor(hex: "1F8A70")
        setupButtons()
        
        fetchUserData()
        
        button1.tag = 1
        button2.tag = 2
        button3.tag = 3
        button4.tag = 4
        
        heightTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        weightTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        goalWeightTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        datePicker.addTarget(self, action: #selector(datePickerDidChange), for: .valueChanged)
    }
    
    func setupButtons() {
        saveButton.layer.cornerRadius = 10
        saveButton.backgroundColor = UIColor.hexStringToUIColor(hex: "004358")
        saveButton.isEnabled = false
        saveButton.backgroundColor = saveButton.backgroundColor?.withAlphaComponent(0.5)
//        saveButton.alpha = 0.5
        cancelButton.tintColor = UIColor.hexStringToUIColor(hex: "004358")
        cancelButton.layer.cornerRadius = 10
        cancelButton.layer.borderWidth = 1.5
        cancelButton.layer.borderColor = UIColor.hexStringToUIColor(hex: "004358").cgColor
        
        configureActivenessButton(button1)
        configureActivenessButton(button2)
        configureActivenessButton(button3)
        configureActivenessButton(button4)
    }
    
    func configureActivenessButton(_ sender: UIButton) {
        sender.layer.cornerRadius = 8
        sender.titleLabel?.textColor = UIColor.hexStringToUIColor(hex: "004358")
        sender.tintColor = .clear
        sender.layer.borderWidth = 1
        sender.layer.borderColor = UIColor.hexStringToUIColor(hex: "004358").cgColor
//        sender.backgroundColor = UIColor.hexStringToUIColor(hex: "004358")
//        sender.backgroundColor = sender.backgroundColor?.withAlphaComponent(0.1)
    }
    
    func fetchUserData() {
        DispatchQueue.main.async {
            if let height = self.initialUserData?.height {
                self.heightTextField.text = "\(height)"
            }
            if let updatedWeight = self.initialUserData?.updatedWeight {
                self.weightTextField.text = "\(updatedWeight)"
            }
            if let goalWeight = self.initialUserData?.goalWeight {
                self.goalWeightTextField.text = "\(goalWeight)"
            }
            if let date = self.initialUserData?.achievementTime {
                self.datePicker.date = date
            }
            if let goal = self.initialUserData?.goal {
                self.goalSegment.selectedSegmentIndex = goal
            }
            if let activeness = self.initialUserData?.activeness {
                self.setInitialButtonBorder(forActiveness: activeness)
            }
        }
    }
    
    func setInitialButtonBorder(forActiveness activeness: Int) {
        let buttons: [UIButton] = [button1, button2, button3, button4]
        for button in buttons where button.tag == activeness {
            button.backgroundColor = UIColor.hexStringToUIColor(hex: "e5e5e5")
//            button.layer.borderWidth = 2
//            button.layer.borderColor = UIColor.hexStringToUIColor(hex: "004358").cgColor
            selectedButton = button
            break
        }
    }
    
    @IBAction func activenessButtonTapped(_ sender: UIButton) {
        let activeness = sender.tag
        updates["activeness"] = activeness
        
        if let previousSelectedButton = selectedButton {
            previousSelectedButton.backgroundColor = .clear
//            previousSelectedButton.layer.borderWidth = 0
        }
        sender.backgroundColor = UIColor.hexStringToUIColor(hex: "e5e5e5")
//        sender.layer.borderWidth = 2
//        sender.layer.borderColor = UIColor.hexStringToUIColor(hex: "004358").cgColor
        
        selectedButton = sender
        checkForChanges()
        print("Activeness set to: \(activeness)")
    }
  
    @IBAction func segmentSwitched(_ sender: UISegmentedControl) {
        updates["goal"] = goalSegment.selectedSegmentIndex
        checkForChanges()
        print("segment == \(goalSegment.selectedSegmentIndex)")
    }
    
    @IBAction func changeSaved(_ sender: UIButton) {
        if let heightText = heightTextField.text,
           let height = Double(heightText), height != initialUserData?.height {
            updates["height"] = height
        }
        if let weightText = weightTextField.text,
           let weight = Double(weightText), weight != initialUserData?.updatedWeight {
            updates["updated_weight"] = weight
        }
        if let goalWeightText = goalWeightTextField.text,
            let goalWeight = Double(goalWeightText), goalWeight != initialUserData?.goalWeight {
            updates["goal_weight"] = goalWeight
        }
        let achievementTime = datePicker.date
        if achievementTime != initialUserData?.achievementTime {
            updates["achievement_time"] = achievementTime
        }
        
        if !updates.isEmpty {
            FirestoreManager.shared.updatePartialUserData(updates: updates) { success in
                if success {
                    print("Data updated successfully")
                    print(self.updates)
                    
                    if let updatedWeight = self.updates["updated_weight"] as? Double {
                        FirestoreManager.shared.postWeightToSubcollection(weight: updatedWeight)
                    }
                    
                } else {
                    print("Failed to update data")
                }
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - Extension: check status

extension RecordManageViewController {
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkForChanges()
    }

    @objc func datePickerDidChange(_ datePicker: UIDatePicker) {
        checkForChanges()
    }

    func checkForChanges() {
        var hasChanged = false
        
        if let heightText = heightTextField.text, let height = Double(heightText), height != initialUserData?.height {
            hasChanged = true
        } else if let weightText = weightTextField.text, let weight = Double(weightText), weight != initialUserData?.updatedWeight {
            hasChanged = true
        } else if let goalWeightText = goalWeightTextField.text, let goalWeight = Double(goalWeightText), goalWeight != initialUserData?.goalWeight {
            hasChanged = true
        } else if datePicker.date != initialUserData?.achievementTime {
            hasChanged = true
        } else if goalSegment.selectedSegmentIndex != initialUserData?.goal {
            hasChanged = true
        } else if let selectedActiveness = selectedButton?.tag, selectedActiveness != initialUserData?.activeness {
            hasChanged = true
        }
        
        saveButton.isEnabled = hasChanged
        let alpha = hasChanged ? 1.0 : 0.3
        saveButton.backgroundColor = saveButton.backgroundColor?.withAlphaComponent(alpha)
    }
}
