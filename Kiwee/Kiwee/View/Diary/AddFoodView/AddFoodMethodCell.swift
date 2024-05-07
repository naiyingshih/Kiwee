//
//  AddFoodViewCell.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import UIKit

protocol AddFoodMethodCellDelegate: AnyObject {
    func searchBarDidChange(text: String)
    func cameraButtonDidTapped()
    func textFieldConfirmed(foodResults: [Food]?)
}

enum AddFoodMethod {
    case imageRecognition
    case search
    case manual
}

class AddFoodMethodCell: UITableViewCell {
    
    weak var delegate: AddFoodMethodCellDelegate?
    
    private lazy var cameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Camera"), for: .normal)
        button.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "搜尋食物"
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.backgroundColor = UIColor.hexStringToUIColor(hex: "EAF4F4")
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "輸入食物名稱"
        setupTextFieldStyle(textField)
        return textField
    }()
    
    private lazy var calorieTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "熱量(kcal/100g)"
        setupTextFieldStyle(textField)
        return textField
    }()
    
    private lazy var carboTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "碳水(100g)"
        setupTextFieldStyle(textField)
        return textField
    }()
    
    private lazy var proteinTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "蛋白(100g)"
        setupTextFieldStyle(textField)
        return textField
    }()
    
    private lazy var fatTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "脂肪(100g)"
        setupTextFieldStyle(textField)
        return textField
    }()
    
    private lazy var fiberTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "纖維(100g)"
        setupTextFieldStyle(textField)
        return textField
    }()
    
    private lazy var confirmButton: UIButton = {
       let button = UIButton()
        button.setTitle("確認", for: .normal)
        button.applyPrimaryStyle(size: 17)
        button.addTarget(self, action: #selector(confirmedTextField), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var clearButton: UIButton = {
       let button = UIButton()
        button.setTitle("清除", for: .normal)
        button.applyThirdStyle(size: 17)
        button.addTarget(self, action: #selector(removeTextField), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private func setupTextFieldStyle(_ textField: UITextField) {
        textField.keyboardType = .decimalPad
        textField.font = UIFont.regular(size: 13)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupTextFieldObservers()
        updateConfirmButtonState(isEnabled: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {}
    
    // MARK: - Status Check Functions
    func setupTextFieldObservers() {
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        calorieTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        carboTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        proteinTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        fatTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        fiberTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    func updateConfirmButtonState(isEnabled: Bool) {
        ButtonManager.updateButtonEnableStatus(for: confirmButton, enabled: isEnabled)
    }
    
    // MARK: - Actions
    @objc func openCamera() {
        guard let delegate = delegate else { return }
        delegate.cameraButtonDidTapped()
    }
    
    @objc func confirmedTextField() {
        guard let delegate = delegate else { return }
        guard let name = nameTextField.text, !name.isEmpty,
              let calorie = calorieTextField.text, !calorie.isEmpty,
              let carbo = carboTextField.text, !carbo.isEmpty,
              let protein = proteinTextField.text, !protein.isEmpty,
              let fat = fatTextField.text, !fat.isEmpty,
              let fiber = fiberTextField.text, !fiber.isEmpty 
        else {
            print("text field cannot be empty")
            return
        }
        let foodResult = Food(
            documentID: "",
            name: name,
            totalCalories: Double("\(calorie)") ?? 0.0,
            nutrients: Nutrient(
                carbohydrates: Double("\(carbo)") ?? 0.0,
                protein: Double("\(protein)") ?? 0.0,
                fat: Double("\(fat)") ?? 0.0,
                fiber: Double("\(fiber)") ?? 0.0
            ),
            image: "",
            quantity: nil,
            section: nil, 
            date: nil
        )
        delegate.textFieldConfirmed(foodResults: [foodResult])
        removeTextField()
    }
    
    @objc func removeTextField() {
        nameTextField.text = ""
        calorieTextField.text = ""
        carboTextField.text = ""
        proteinTextField.text = ""
        fatTextField.text = ""
        fiberTextField.text = ""
        updateConfirmButtonState(isEnabled: false)
    }
    
    @objc func textFieldDidChange() {
        let areAllTextFieldsNotEmpty = !nameTextField.text!.isEmpty &&
        !calorieTextField.text!.isEmpty &&
        !carboTextField.text!.isEmpty &&
        !proteinTextField.text!.isEmpty &&
        !fatTextField.text!.isEmpty &&
        !fiberTextField.text!.isEmpty
        
        updateConfirmButtonState(isEnabled: areAllTextFieldsNotEmpty)
    }
    
    // MARK: - Method Configure
    func configureCellForMethod(_ method: AddFoodMethod?) {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        switch method {
        case .imageRecognition:
            setupCameraButton()
        case .search:
            setupSearchBar()
        case .manual:
            setupTextField()
        default:
            break
        }
    }
    
    private func setupCameraButton() {
        contentView.addSubview(cameraButton)
        
        NSLayoutConstraint.activate([
            cameraButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            cameraButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            cameraButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cameraButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            cameraButton.heightAnchor.constraint(equalToConstant: 40),
            cameraButton.widthAnchor.constraint(equalTo: cameraButton.heightAnchor)
        ])
    }
    
    private func setupSearchBar() {
        contentView.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            searchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            searchBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            searchBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupTextField() {
        contentView.addSubview(nameTextField)
        contentView.addSubview(calorieTextField)
        contentView.addSubview(carboTextField)
        contentView.addSubview(proteinTextField)
        contentView.addSubview(fatTextField)
        contentView.addSubview(fiberTextField)
        contentView.addSubview(confirmButton)
        contentView.addSubview(clearButton)
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            calorieTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            calorieTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            calorieTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 12),
            
            carboTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            carboTextField.topAnchor.constraint(equalTo: calorieTextField.bottomAnchor, constant: 12),
            
            proteinTextField.leadingAnchor.constraint(equalTo: carboTextField.trailingAnchor, constant: 8),
            proteinTextField.topAnchor.constraint(equalTo: carboTextField.topAnchor),
            
            fatTextField.leadingAnchor.constraint(equalTo: proteinTextField.trailingAnchor, constant: 8),
            fatTextField.topAnchor.constraint(equalTo: carboTextField.topAnchor),
            
            fiberTextField.leadingAnchor.constraint(equalTo: fatTextField.trailingAnchor, constant: 8),
            fiberTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            fiberTextField.topAnchor.constraint(equalTo: carboTextField.topAnchor),
            
            confirmButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -60),
            confirmButton.widthAnchor.constraint(equalToConstant: 100),
            confirmButton.topAnchor.constraint(equalTo: carboTextField.bottomAnchor, constant: 24),
            confirmButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            clearButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 60),
            clearButton.widthAnchor.constraint(equalToConstant: 100),
            clearButton.topAnchor.constraint(equalTo: carboTextField.bottomAnchor, constant: 24),
            clearButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
        
        let equalWidths = [carboTextField, proteinTextField, fatTextField, fiberTextField].map {
            $0.widthAnchor.constraint(equalTo: carboTextField.widthAnchor)
        }
        NSLayoutConstraint.activate(equalWidths)

        // Adjust content hugging and compression resistance
        let textFields = [carboTextField, proteinTextField, fatTextField, fiberTextField]
        textFields.forEach { textField in
            textField.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
            textField.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)
        }
    }
    
}

// MARK: - UISearchBarDelegate
extension AddFoodMethodCell: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let delegate = delegate else { return }
        guard let searchText = searchBar.text else { return }
        delegate.searchBarDidChange(text: searchText)
        // Dismiss the keyboard
        searchBar.resignFirstResponder()
        searchBar.text = ""
    }

}
