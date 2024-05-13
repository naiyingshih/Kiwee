//
//  AddFoodViewCell.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import UIKit

protocol AddFoodMethodCellDelegate: AnyObject {
    func searchBarDidChange(text: String)
    func seletedSearchResult(at indexPath: Int)
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
    var collectionView: UICollectionView!
    
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
        textField.font = UIFont.regular(size: 13)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
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
        button.setTitle("完成", for: .normal)
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
        setupCollectionView()
        updateConfirmButtonState(isEnabled: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {}
    
    // MARK: - Status Check Functions
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 4
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
//        layout.itemSize = CGSize(width: 100, height: 30) // Adjust based on your needs
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.applyCardStyle(backgroundColor: KWColor.cardBackground)
        collectionView.register(SearchListCollectionViewCell.self, forCellWithReuseIdentifier: "SearchListCollectionViewCell")
        collectionView.tag = 1
        
    }
    
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
        contentView.addSubview(collectionView)
       
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            searchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            searchBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
//            searchBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            collectionView.heightAnchor.constraint(equalToConstant: 100)
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

// MARK: - CollectionViewCell

class SearchListCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: AddFoodMethodCellDelegate?
    var indexPath: Int?
    
    lazy var foodLabel: UILabel = {
        let label = UILabel()
        label.applyContent(size: 16, color: .black)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var checkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.tintColor = KWColor.darkG
        button.tag = 0
        button.addTarget(self, action: #selector(setSeleted), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
        self.applyCardStyle()
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLabel()
//        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLabel() {
        contentView.addSubview(foodLabel)
        contentView.addSubview(checkButton)
        
        NSLayoutConstraint.activate([
            foodLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            foodLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            foodLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            foodLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            checkButton.centerYAnchor.constraint(equalTo: foodLabel.centerYAnchor),
            checkButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    @objc func setSeleted() {
        let newState = checkButton.tag == 0 ? 1 : 0
        checkButton.setImage(UIImage(systemName: newState == 1 ? "checkmark.circle" : "circle"), for: .normal)
        checkButton.tag = newState
        
        if let indexPath = self.indexPath {
            delegate?.seletedSearchResult(at: indexPath)
        }
    }
    
    func updateResults(_ results: Food) {
        foodLabel.text = results.name
    }
    
}
