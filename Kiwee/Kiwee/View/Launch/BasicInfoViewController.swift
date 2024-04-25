//
//  LaunchViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/25.
//

import UIKit

enum Block {
    case gender
    case age
    case activeness
    case bodyInfo
    case achievement
}

class BasicInfoViewController: UIViewController {
    
    private var currentBlock: Block?
    private var selectedGenderButton: UIButton?
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var genderStackView: UIStackView!
    @IBOutlet weak var menButton: UIButton!
    @IBOutlet weak var womenButton: UIButton!
    @IBOutlet weak var ageStackView: UIStackView!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialUI()
        setupTextFieldObservers()
    }
    
    func updateNextButtonState(isEnabled: Bool) {
        nextButton.isEnabled = isEnabled
        let alpha: CGFloat = isEnabled ? 1.0 : 0.5
        nextButton.backgroundColor = nextButton.backgroundColor?.withAlphaComponent(alpha)
    }
    
    func setInitialUI() {
        menButton.tag = 0
        womenButton.tag = 1
        genderStackView.isHidden = true
        ageStackView.isHidden = true
        nextButton.layer.cornerRadius = 8
        ageTextField.keyboardType = .numberPad
        updateNextButtonState(isEnabled: false)
    }
    
    func setupTextFieldObservers() {
        nameTextField.addTarget(self, action: #selector(nameTextFieldDidChange), for: .editingChanged)
        ageTextField.addTarget(self, action: #selector(ageTextFieldDidChange), for: .editingChanged)
    }
    
    @objc func nameTextFieldDidChange() {
        if let nameTextField = nameTextField.text, !nameTextField.isEmpty {
            updateNextButtonState(isEnabled: true)
        } else {
            updateNextButtonState(isEnabled: false)
        }
    }
    
    @objc func ageTextFieldDidChange() {
        if let ageTextField = ageTextField.text, !ageTextField.isEmpty {
            updateNextButtonState(isEnabled: true)
        } else {
            updateNextButtonState(isEnabled: false)
        }
    }
    
    @IBAction func genderButtonTapped(_ sender: UIButton) {
        if let previousSelectedButton = selectedGenderButton {
            previousSelectedButton.layer.borderWidth = 0
        }
        sender.layer.borderWidth = 2
        sender.layer.cornerRadius = 8
        sender.layer.borderColor = UIColor.hexStringToUIColor(hex: "004358").cgColor
        
        selectedGenderButton = sender
        
        updateNextButtonState(isEnabled: true)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if currentBlock == nil {
            // Show gender block
            genderStackView.isHidden = false
            currentBlock = .gender
            updateNextButtonState(isEnabled: false)
        } else if currentBlock == .gender {
            // Show age block
            ageStackView.isHidden = false
            currentBlock = .age
            updateNextButtonState(isEnabled: false)
        } else if currentBlock == .age {
            // Save data to UserDefaults
            if let name = nameTextField.text,
               let age = ageTextField.text,
               let selectedGender = selectedGenderButton?.tag {
                UserDefaults.standard.set(name, forKey: "name")
                UserDefaults.standard.set(selectedGender, forKey: "gender")
                UserDefaults.standard.set(age, forKey: "age")
            }
            
            // Present VC
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            if let goalVC = storyboard.instantiateViewController(withIdentifier: "GoalViewController") as? GoalViewController {
                goalVC.modalPresentationStyle = .fullScreen
                self.present(goalVC, animated: true, completion: nil)
            }
        }
    }
    
}
