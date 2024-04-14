//
//  AddFoodViewCell.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import UIKit

@objc protocol AddFoodMethodCellDelegate: AnyObject {
    @objc optional func searchBarDidChange(text: String)
    @objc optional func cameraButtonDidTapped()
}

enum AddFoodMethod {
    case imageRecognition
    case search
    case manual
}

class AddFoodMethodCell: UITableViewCell {
    
    weak var delegate: AddFoodMethodCellDelegate?
    
    lazy var cameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "camera"), for: .normal)
        button.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "搜尋食物"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "輸入食物名稱"
        textField.font = UIFont.systemFont(ofSize: 12)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var calorieTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "總熱量(kcal)"
        textField.font = UIFont.systemFont(ofSize: 12)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var carboTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "碳水(100g)"
        textField.font = UIFont.systemFont(ofSize: 12)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var proteinTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "蛋白(100g)"
        textField.font = UIFont.systemFont(ofSize: 12)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var fatTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "脂肪(100g)"
        textField.font = UIFont.systemFont(ofSize: 12)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var fiberTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "纖維(100g)"
        textField.font = UIFont.systemFont(ofSize: 12)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
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
        delegate.cameraButtonDidTapped?()
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
    
//    func setupTextField() {
//        addTextFieldsToContentView()
//        activateConstraints()
//        adjustContentHuggingAndCompressionResistance()
//    }
//
//    private func addTextFieldsToContentView() {
//        [nameTextField, calorieTextField, carboTextField, proteinTextField, fatTextField, fiberTextField].forEach { textField in
//            contentView.addSubview(textField)
//            textField.translatesAutoresizingMaskIntoConstraints = false
//        }
//    }
//
//    private func activateConstraints() {
//        NSLayoutConstraint.activate([
//            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
//            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
//            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
//            
//            calorieTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 12),
//            calorieTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
//            calorieTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
//            
//            setupHorizontalFieldsConstraints()
//        ].compactMap { $0 as? NSLayoutConstraint })
//    }
//
//    private func setupHorizontalFieldsConstraints() -> [NSLayoutConstraint] {
//        let fields = [carboTextField, proteinTextField, fatTextField, fiberTextField]
//        
//        var constraints = [fields.first!.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24)]
//        constraints.append(fields.last!.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24))
//        
//        for (index, textField) in fields.enumerated() {
//            if index > 0 {
//                constraints.append(textField.leadingAnchor.constraint(equalTo: fields[index - 1].trailingAnchor, constant: 8))
//            }
//            constraints.append(textField.widthAnchor.constraint(equalTo: carboTextField.widthAnchor))
//            constraints.append(contentsOf: [
//                textField.topAnchor.constraint(equalTo: calorieTextField.bottomAnchor, constant: 12),
//                textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
//            ])
//        }
//        return constraints
//    }
//
//    private func adjustContentHuggingAndCompressionResistance() {
//        let textFields = [carboTextField, proteinTextField, fatTextField, fiberTextField]
//        textFields.forEach { textField in
//            textField.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
//            textField.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)
//        }
//    }
    
    func setupTextField() {
        contentView.addSubview(nameTextField)
        contentView.addSubview(calorieTextField)
        contentView.addSubview(carboTextField)
        contentView.addSubview(proteinTextField)
        contentView.addSubview(fatTextField)
        contentView.addSubview(fiberTextField)
        
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
            proteinTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            fatTextField.leadingAnchor.constraint(equalTo: proteinTextField.trailingAnchor, constant: 8),
            fatTextField.topAnchor.constraint(equalTo: carboTextField.topAnchor),
            fatTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            fiberTextField.leadingAnchor.constraint(equalTo: fatTextField.trailingAnchor, constant: 8),
            fiberTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            fiberTextField.topAnchor.constraint(equalTo: carboTextField.topAnchor),
            fiberTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
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
        delegate.searchBarDidChange?(text: searchText)
    }
    
}
