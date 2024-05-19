//
//  CustomFunctionManager.swift
//  Kiwee
//
//  Created by NY on 2024/5/1.
//

import UIKit

// MARK: - RDA Calculation
class BMRUtility {
    
    static func calculateBMR(with userData: UserData) -> Double {
        let weight = userData.updatedWeight ?? userData.initialWeight
        let height = userData.height
        let age = userData.age
        let gender = userData.gender
        
        var BMR = calculateBMRForGender(gender, weight: weight, height: height, age: age)
        BMR = adjustBMRForActivityLevel(BMR, activeness: userData.activeness)
        BMR = adjustBMRForGoal(BMR, goal: userData.goal)
        
        return BMR
    }

    static func calculateBMRForGender(_ gender: Int, weight: Double, height: Double, age: Int) -> Double {
        switch gender {
        case 1: // Male
            return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * Double(age))
        case 2: // Female
            return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * Double(age))
        default:
            return 0
        }
    }

    static func adjustBMRForActivityLevel(_ BMR: Double, activeness: Int) -> Double {
        switch activeness {
        case 4:
            return BMR * 1.2
        case 3:
            return BMR * 1.55
        case 2:
            return BMR * 1.725
        case 1:
            return BMR * 1.9
        default:
            return BMR
        }
    }

    static func adjustBMRForGoal(_ BMR: Double, goal: Int) -> Double {
        switch goal {
        case 0: // Weight loss
            return BMR - 300
        case 1: // Weight gain
            return BMR + 300
        case 2: // Weight maintenance
            return BMR
        default:
            return BMR
        }
    }
    
}

// MARK: - Button Status
class ButtonManager {
    
    static func updateButtonEnableStatus(for button: UIButton, enabled: Bool) {
        button.isEnabled = enabled
        button.backgroundColor = enabled ? button.backgroundColor?.withAlphaComponent(1.0) : button.backgroundColor?.withAlphaComponent(0.5)
    }
    
    static func setSelectedButtonStatus(currentButton: UIButton, previousButton: UIButton?, additionalUIUpdates: (() -> Void)?) {
        
        if let previousSelectedButton = previousButton {
            previousSelectedButton.layer.borderWidth = 0
        }
        
        currentButton.layer.borderWidth = 1.5
        currentButton.layer.cornerRadius = 10
        currentButton.layer.borderColor = KWColor.darkB.cgColor
        
        additionalUIUpdates?()
    }
    
}

// MARK: - Alert Manager
class AlertManager {
    
}
