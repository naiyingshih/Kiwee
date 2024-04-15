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
    func textFieldConfirmed(foodResult: [Food]?)
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
        button.setImage(UIImage(systemName: "camera"), for: .normal)
        button.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "搜尋食物"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "輸入食物名稱"
        textField.font = UIFont.systemFont(ofSize: 12)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var calorieTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "總熱量(kcal)"
        textField.font = UIFont.systemFont(ofSize: 12)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var carboTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "碳水(100g)"
        textField.font = UIFont.systemFont(ofSize: 12)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var proteinTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "蛋白(100g)"
        textField.font = UIFont.systemFont(ofSize: 12)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var fatTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "脂肪(100g)"
        textField.font = UIFont.systemFont(ofSize: 12)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var fiberTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "纖維(100g)"
        textField.font = UIFont.systemFont(ofSize: 12)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var confirmButton: UIButton = {
       let button = UIButton()
        button.setTitle("確認", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.hexStringToUIColor(hex: "1F8A70")
        button.addTarget(self, action: #selector(confirmedTextField), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {}
    
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
            date: nil)
        delegate.textFieldConfirmed(foodResult: [foodResult])
    }
    
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
    
    func setupCameraButton() {
        contentView.addSubview(cameraButton)
        
        NSLayoutConstraint.activate([
            cameraButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            cameraButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            cameraButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    func setupSearchBar() {
        contentView.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            searchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            searchBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            searchBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func setupTextField() {
        contentView.addSubview(nameTextField)
        contentView.addSubview(calorieTextField)
        contentView.addSubview(carboTextField)
        contentView.addSubview(proteinTextField)
        contentView.addSubview(fatTextField)
        contentView.addSubview(fiberTextField)
        contentView.addSubview(confirmButton)
        
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

            confirmButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 60),
            confirmButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -60),
            confirmButton.topAnchor.constraint(equalTo: carboTextField.bottomAnchor, constant: 24),
            confirmButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
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

extension AddFoodMethodCell: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let delegate = delegate else { return }
        delegate.searchBarDidChange(text: searchText)
    }
    
}
