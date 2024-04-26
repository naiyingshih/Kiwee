//
//  GoalViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/25.
//

import UIKit

class GoalViewController: UIViewController {
    
    private var currentPage: Block?
    private var selectedGoalButton: UIButton?
    private var selectedActivenessButton: UIButton?
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var goalStackView: UIStackView!
    @IBOutlet weak var loseWeightButton: UIButton!
    @IBOutlet weak var gainWeightButton: UIButton!
    @IBOutlet weak var maintainWeightButton: UIButton!
    @IBOutlet weak var activenessStackView: UIStackView!
    @IBOutlet weak var active4Button: UIButton!
    @IBOutlet weak var active3Button: UIButton!
    @IBOutlet weak var active2Button: UIButton!
    @IBOutlet weak var active1Button: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var bodyInfoStackView: UIStackView!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    
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
        let defaults = UserDefaults.standard
        let name = defaults.string(forKey: "name")
        welcomeLabel.text = "嗨！\(name ?? "")"
        loseWeightButton.tag = 0
        gainWeightButton.tag = 1
        maintainWeightButton.tag = 2
        
        active1Button.tag = 1
        active2Button.tag = 2
        active3Button.tag = 3
        active4Button.tag = 4
        
        activenessStackView.isHidden = true
        bodyInfoStackView.isHidden = true
        nextButton.layer.cornerRadius = 8
        heightTextField.keyboardType = .decimalPad
        weightTextField.keyboardType = .decimalPad
        updateNextButtonState(isEnabled: false)
    }
    
    @IBAction func goalButtonTapped(_ sender: UIButton) {
        if let previousSelectedButton = selectedGoalButton {
            previousSelectedButton.layer.borderWidth = 0
        }
        sender.layer.borderWidth = 2
        sender.layer.cornerRadius = 8
        sender.layer.borderColor = UIColor.hexStringToUIColor(hex: "004358").cgColor
        
        selectedGoalButton = sender
        
        updateNextButtonState(isEnabled: true)
    }
    
    @IBAction func activenessButtonTapped(_ sender: UIButton) {
        if let previousSelectedButton = selectedActivenessButton {
            previousSelectedButton.layer.borderWidth = 0
        }
        sender.layer.borderWidth = 2
        sender.layer.cornerRadius = 8
        sender.layer.borderColor = UIColor.hexStringToUIColor(hex: "004358").cgColor
        
        selectedActivenessButton = sender
        
        updateNextButtonState(isEnabled: true)
    }
    
    func setupTextFieldObservers() {
        heightTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        weightTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc func textFieldDidChange() {
        if let heightText = heightTextField.text, !heightText.isEmpty,
           let weightText = weightTextField.text, !weightText.isEmpty {
            updateNextButtonState(isEnabled: true)
        } else {
            updateNextButtonState(isEnabled: false)
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if currentPage == nil {
            // Show activeness page
            goalStackView.isHidden = true
            activenessStackView.isHidden = false
            currentPage = .activeness
            updateNextButtonState(isEnabled: false)
        } else if currentPage == .activeness {
            // Show bodyInfo page
            activenessStackView.isHidden = true
            goalStackView.isHidden = true
            bodyInfoStackView.isHidden = false
            currentPage = .bodyInfo
            updateNextButtonState(isEnabled: false)
        } else if currentPage == .bodyInfo {
            
            if let selectedGoal = selectedGoalButton?.tag,
               let selectedActiveness = selectedActivenessButton?.tag,
               let height = heightTextField.text,
               let weight = weightTextField.text {
                UserDefaults.standard.set(selectedGoal, forKey: "goal")
                UserDefaults.standard.set(selectedActiveness, forKey: "activeness")
                UserDefaults.standard.set(height, forKey: "height")
                UserDefaults.standard.set(weight, forKey: "initial_weight")
            }
            
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            if let lastVC = storyboard.instantiateViewController(withIdentifier: "LastViewController") as? LastViewController {
                lastVC.modalPresentationStyle = .fullScreen
                self.present(lastVC, animated: true, completion: nil)
            }
        }
    }
    
}
