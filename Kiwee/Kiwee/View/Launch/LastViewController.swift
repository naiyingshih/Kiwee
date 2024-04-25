//
//  LastViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/25.
//

import UIKit

class LastViewController: UIViewController {
    
    private var currentArea: Block?
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var goalWeightStackView: UIStackView!
    @IBOutlet weak var goalWeightTextField: UITextField!
    @IBOutlet weak var achieveStackView: UIStackView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialUI()
    }
    
    func updateNextButtonState(isEnabled: Bool) {
        nextButton.isEnabled = isEnabled
        let alpha: CGFloat = isEnabled ? 1.0 : 0.5
        nextButton.backgroundColor = nextButton.backgroundColor?.withAlphaComponent(alpha)
    }
    
    func setInitialUI() {
        achieveStackView.isHidden = true
        
        goalWeightTextField.keyboardType = .decimalPad
        goalWeightTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        datePicker.addTarget(self, action: #selector(datePickerDidChange), for: .valueChanged)
        
        label1.text = "BMI："
        label2.text = "理想體重：kg"
        cardView.backgroundColor = UIColor.hexStringToUIColor(hex: "004358")
        cardView.backgroundColor = cardView.backgroundColor?.withAlphaComponent(0.2)
        cardView.layer.cornerRadius = 10
        
        nextButton.layer.cornerRadius = 8
        updateNextButtonState(isEnabled: false)
    }
    
    func setupDatePicker() {
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: goalWeightTextField.centerXAnchor),
            datePicker.centerYAnchor.constraint(equalTo: goalWeightTextField.centerYAnchor)
        ])
        datePicker.datePickerMode = .date
    }
    
    @objc func textFieldDidChange() {
        if let textField = goalWeightTextField.text, !textField.isEmpty {
            updateNextButtonState(isEnabled: true)
        } else {
            updateNextButtonState(isEnabled: false)
        }
    }
    
    @objc func datePickerDidChange(_ datePicker: UIDatePicker) {
        if datePicker.date != Date() {
            updateNextButtonState(isEnabled: true)
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if currentArea == nil {
            // Show achievement area
            goalWeightStackView.isHidden = true
            setupDatePicker()
            achieveStackView.isHidden = false
            label1.text = "您一天建議攝取熱量為 kcal"
            label2.text = "您將在 天候達成目標！"
            currentArea = .achievement
            updateNextButtonState(isEnabled: false)
        } else if currentArea == .achievement {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            if let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController {
                signInVC.modalPresentationStyle = .pageSheet
                self.present(signInVC, animated: true, completion: nil)
            }
        }
    }

}
