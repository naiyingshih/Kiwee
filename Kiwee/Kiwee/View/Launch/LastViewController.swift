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
    
    @IBOutlet weak var welcomeLabel: UILabel!
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
        
        setupInitialLabels()
        cardView.backgroundColor = UIColor.hexStringToUIColor(hex: "004358")
        cardView.backgroundColor = cardView.backgroundColor?.withAlphaComponent(0.2)
        cardView.layer.cornerRadius = 10
        
        nextButton.layer.cornerRadius = 8
        updateNextButtonState(isEnabled: false)
    }
    
    func setupInitialLabels() {
        let defaults = UserDefaults.standard
        
        let name = defaults.string(forKey: "name")

        let height = defaults.double(forKey: "height")
        let initialWeight = defaults.double(forKey: "initial_weight")
        
        let BMI = initialWeight / (height * height) * 10000
        let formattedBMI = String(format: "%.1f", BMI)
        
        let lowRange = 18.5 * height * height / 10000
        let highRange = 24 * height * height / 10000
        let formattedLow = String(format: "%.0f", lowRange)
        let formattedHigh = String(format: "%.0f", highRange)
        
        welcomeLabel.text = "嗨！\(name ?? "")"
        label1.text = "BMI：\(formattedBMI)"
        label2.text = "理想體重：\(formattedLow) - \(formattedHigh) kg"
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
            let achievement = datePicker.date
            UserDefaults.standard.set(achievement, forKey: "achievement_time")
            updateLabel()
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if currentArea == nil {
            // Show achievement area
            goalWeightStackView.isHidden = true
            setupDatePicker()
            fetchLabelsData()
            achieveStackView.isHidden = false
            currentArea = .achievement
            updateNextButtonState(isEnabled: false)
        } else if currentArea == .achievement {
            
            if let goalWeight = goalWeightTextField.text {
                UserDefaults.standard.set(goalWeight, forKey: "goal_weight")
            }
            
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            if let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController {
                signInVC.modalPresentationStyle = .pageSheet
                self.present(signInVC, animated: true, completion: nil)
            }
            postUserInfo()
        }
    }
    
    func fetchLabelsData() {
        let defaults = UserDefaults.standard
        
        let height = defaults.double(forKey: "height")
        let RDA = (height * height) / 10000 * 22 * 25
        let formattedRDA = String(format: "%.0f", RDA)

        label1.text = "您一天建議攝取熱量 \(formattedRDA) kcal"
        label2.text = "您將在 ... 天後達成目標！"
        
    }
    
    func updateLabel() {
        let defaults = UserDefaults.standard
        
        let achievementTime = defaults.object(forKey: "achievement_time") as? Date ?? Date()
        let today = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: today, to: achievementTime)
        let remainDay = components.day
        label2.text = "您將在\((remainDay ?? 0) + 1)天後達成目標！"
    }
    
    func postUserInfo() {
        let defaults = UserDefaults.standard
        
        let name = defaults.string(forKey: "name") ?? ""
        let gender = defaults.integer(forKey: "gender")
        let age = defaults.integer(forKey: "age")
        let goal = defaults.integer(forKey: "goal")
        let activeness = defaults.integer(forKey: "activeness")
        let height = defaults.double(forKey: "height")
        let initialWeight = defaults.double(forKey: "initial_weight")
        let achievementTime = defaults.object(forKey: "achievement_time") as? Date ?? Date()
        let goalWeight = defaults.double(forKey: "goal_weight")
        
        let userData = UserData(
            id: "\(UUID())",
            name: name,
            gender: gender,
            age: age,
            goal: goal,
            activeness: activeness,
            height: height,
            initialWeight: initialWeight,
            updatedWeight: initialWeight,
            goalWeight: goalWeight,
            achievementTime: achievementTime)
        
        FirestoreManager.shared.postUserData(input: userData) { success in
            if success {
                print("user data add successfully")
            } else {
                print("Error adding user data")
            }
        }
    }
    
}
