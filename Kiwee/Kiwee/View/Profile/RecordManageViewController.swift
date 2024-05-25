//
//  RecordManageViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/18.
//

import UIKit

class RecordManageViewController: UIViewController {
    
    let firebaseManager = FirebaseManager.shared
    
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
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = KWColor.darkB
        backView.backgroundColor = KWColor.background
        backView.layer.cornerRadius = 20
        datePicker.tintColor = KWColor.darkG
        setupButtons()
        
        fetchUserData()
        
        heightTextField.keyboardType = .decimalPad
        weightTextField.keyboardType = .decimalPad
        goalWeightTextField.keyboardType = .decimalPad
        heightTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        weightTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        goalWeightTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        datePicker.addTarget(self, action: #selector(datePickerDidChange), for: .valueChanged)
    }
    
    // MARK: - UI Setting Functions
    func setupButtons() {
        saveButton.setTitle("確認變更", for: .normal)
        saveButton.applyPrimaryStyle(size: 17)
        ButtonManager.updateButtonEnableStatus(for: saveButton, enabled: false)

        cancelButton.setTitle("取消", for: .normal)
        cancelButton.applyThirdStyle(size: 17)

        configureActivenessButton(button1)
        configureActivenessButton(button2)
        configureActivenessButton(button3)
        configureActivenessButton(button4)
        button1.tag = 1
        button2.tag = 2
        button3.tag = 3
        button4.tag = 4
    }
    
    func configureActivenessButton(_ sender: UIButton) {
        sender.layer.cornerRadius = 8
        sender.titleLabel?.textColor = KWColor.darkB
        sender.tintColor = .clear
        sender.layer.borderWidth = 1
        sender.layer.borderColor = KWColor.darkB.cgColor
    }
    
    func fetchUserData() {
        guard let initialUserData = self.initialUserData else { return }
        DispatchQueue.main.async {
            self.heightTextField.text = "\(initialUserData.height)"
            self.weightTextField.text = "\(initialUserData.updatedWeight ?? initialUserData.initialWeight)"
            self.goalWeightTextField.text = "\(initialUserData.goalWeight)"
            self.datePicker.date = initialUserData.achievementTime
            self.goalSegment.selectedSegmentIndex = initialUserData.goal
            self.setInitialButtonBorder(forActiveness: initialUserData.activeness)
        }
    }
    
    func setInitialButtonBorder(forActiveness activeness: Int) {
        let buttons: [UIButton] = [button1, button2, button3, button4]
        for button in buttons where button.tag == activeness {
            button.backgroundColor = UIColor.hexStringToUIColor(hex: "CCCCCC")
            selectedButton = button
            break
        }
    }
    
    // MARK: - Actions
    @IBAction func activenessButtonTapped(_ sender: UIButton) {
        let activeness = sender.tag
        updates["activeness"] = activeness
        
        if let previousSelectedButton = selectedButton {
            previousSelectedButton.backgroundColor = .clear
        }
        sender.backgroundColor = UIColor.hexStringToUIColor(hex: "CCCCCC")
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
            guard let userID = firebaseManager.userID else { return }
            firebaseManager.updatePartialUserData(userID: userID, updates: updates) { success in
                if success {
                    print("Data updated successfully")
                    print(self.updates)
                    
                    if let updatedWeight = self.updates["updated_weight"] as? Double {
                        self.postWeightToSubcollection(weight: updatedWeight)
                        UserDefaults.standard.set(updatedWeight, forKey: "updated_weight")
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
    
    func postWeightToSubcollection(weight: Double) {
        guard let userID = firebaseManager.userID else { return }
        let weightData = WeightData(date: Date(), weight: weight)
        
        firebaseManager.fetchDocumentID(UserID: userID, collection: .users) { [weak self] result in
            switch result {
            case .success(let documentID):
                self?.firebaseManager.addDataToSub(to: .users, documentID: documentID, subcollection: "current_weight", data: weightData) { result in
                    switch result {
                    case .success:
                        print("Document added to subcollection successfully")
                    case .failure(let error):
                        print("Error adding document to subcollection: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("Error adding user data: \(error.localizedDescription)")
            }
        }
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
        guard let initialUserData = self.initialUserData else { return }
        var hasChanged = false
        
        if let heightText = heightTextField.text, let height = Double(heightText), height != initialUserData.height {
            hasChanged = true
        } else if let weightText = weightTextField.text, let weight = Double(weightText), weight != initialUserData.updatedWeight ?? initialUserData.initialWeight {
            hasChanged = true
        } else if let goalWeightText = goalWeightTextField.text, let goalWeight = Double(goalWeightText), goalWeight != initialUserData.goalWeight {
            hasChanged = true
        } else if datePicker.date != initialUserData.achievementTime {
            hasChanged = true
        } else if goalSegment.selectedSegmentIndex != initialUserData.goal {
            hasChanged = true
        } else if let selectedActiveness = selectedButton?.tag, selectedActiveness != initialUserData.activeness {
            hasChanged = true
        }
        
        ButtonManager.updateButtonEnableStatus(for: saveButton, enabled: hasChanged)
    }
}
