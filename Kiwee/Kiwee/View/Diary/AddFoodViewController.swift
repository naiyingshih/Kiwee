//
//  AddFoodViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import UIKit
import Vision

class AddFoodViewController: UIViewController {
    
    var sectionIndex: Int?
    var currentMethod: AddFoodMethod?
    
    var foodResult: [Food] = []
    var filteredFoodItems: [Food] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                if !self.filteredFoodItems.isEmpty {
                    self.updateConfirmButtonState(isEnabled: true)
                } else {
                    self.updateConfirmButtonState(isEnabled: false)
                }
            }
        }
    }
    var recentFoods: [Food] = []
    var selectedDate: Date?
    var updatedQuantity: Double?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var imageRecognizeButton: UIButton!
    @IBOutlet weak var searchFoodButton: UIButton!
    @IBOutlet weak var manualButton: UIButton!
    
    @IBOutlet weak var underlineView: UIView!
    private var indicatorView = UIView()
    var indicatorCenterXConstraint: NSLayoutConstraint?
    var indicatorWidthConstraint: NSLayoutConstraint?
    
    lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hexStringToUIColor(hex: "f8f7f2")
        view.addTopBorder(color: .lightGray, width: 0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("確認加入", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.hexStringToUIColor(hex: "004358")
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(confirmed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBottomBlock()
        setupInitialUI()
        setupNavigationItemUI()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AddFoodMethodCell.self, forCellReuseIdentifier: "AddFoodMethodCell")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
        fetchRecentRecord()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func setupInitialUI() {
        view.addSubview(indicatorView)
        indicatorView.backgroundColor = UIColor.hexStringToUIColor(hex: "FFE11A")
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorWidthConstraint = indicatorView.widthAnchor.constraint(equalTo: imageRecognizeButton.widthAnchor)
        indicatorCenterXConstraint = indicatorView.centerXAnchor.constraint(equalTo: imageRecognizeButton.centerXAnchor)
        NSLayoutConstraint.activate([
            indicatorWidthConstraint!,
            indicatorCenterXConstraint!,
            indicatorView.bottomAnchor.constraint(equalTo: underlineView.bottomAnchor),
            indicatorView.heightAnchor.constraint(equalToConstant: 2.5)
        ])

        buttonStackView.backgroundColor = UIColor.hexStringToUIColor(hex: "004358")
        view.backgroundColor = UIColor.hexStringToUIColor(hex: "004358")
        imageRecognizeButton.tintColor = .white
        searchFoodButton.tintColor = .lightGray
        manualButton.tintColor = .lightGray
        updateConfirmButtonState(isEnabled: false)
        currentMethod = .imageRecognition
    }
    
    func setupNavigationItemUI() {
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(navigateBack))
        barButtonItem.tintColor = UIColor.hexStringToUIColor(hex: "FFE11A")
        navigationItem.leftBarButtonItem = barButtonItem
    }
    
    func setupBottomBlock() {
        view.addSubview(bottomView)
        bottomView.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 120),
            
            confirmButton.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor, constant: -8),
            confirmButton.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 24),
            confirmButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -24),
            confirmButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    func updateConfirmButtonState(isEnabled: Bool) {
        confirmButton.isEnabled = isEnabled
        let alpha: CGFloat = isEnabled ? 1.0 : 0.5
        confirmButton.backgroundColor = confirmButton.backgroundColor?.withAlphaComponent(alpha)
    }
    
    @IBAction func imageRecognizeButtonTapped(_ sender: UIButton) {
        updateButtonColors(selectedButton: sender)
        updateBottomBorder(for: sender)
        currentMethod = .imageRecognition
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    @IBAction func searchFoodButtonTapped(_ sender: UIButton) {
        updateButtonColors(selectedButton: sender)
        updateBottomBorder(for: sender)
        currentMethod = .search
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    @IBAction func manualButtonTapped(_ sender: UIButton) {
        updateButtonColors(selectedButton: sender)
        updateBottomBorder(for: sender)
        currentMethod = .manual
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    func updateBottomBorder(for selectedButton: UIButton) {
        // Deactivate the existing centerX constraint
        indicatorCenterXConstraint?.isActive = false
        
        // Create a new centerX constraint to align the indicator with the selected button
        indicatorCenterXConstraint = indicatorView.centerXAnchor.constraint(equalTo: selectedButton.centerXAnchor)
        indicatorCenterXConstraint?.isActive = true
 
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded() // Animates the constraint changes
        }
    }
    
    private func updateButtonColors(selectedButton: UIButton) {
        imageRecognizeButton.tintColor = .lightGray
        searchFoodButton.tintColor = .lightGray
        manualButton.tintColor = .lightGray
        selectedButton.tintColor = .white
    }
    
    @objc func navigateBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func confirmed() {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? ResultCell else { return }
        guard !filteredFoodItems.isEmpty else {
            print("No food result")
            return
        }
        if let quantityText = cell.quantityTextField.text, let quantity = Double(quantityText) {
            guard let index = self.sectionIndex else { return }
            var calculatedIntakeDataArray: [Food] = []
            
            for filteredFoodItem in filteredFoodItems {
                let foodInput = Food(documentID: filteredFoodItem.documentID, 
                                     name: filteredFoodItem.name,
                                     totalCalories: filteredFoodItem.totalCalories,
                                     nutrients: filteredFoodItem.nutrients,
                                     image: filteredFoodItem.image,
                                     quantity: quantity,
                                     section: index,
                                     date: filteredFoodItem.date)
                if let calculatedIntakeData = calculateIntakeData(input: foodInput) {
                    calculatedIntakeDataArray.insert(calculatedIntakeData, at: 0)
                }
            }
            FirestoreManager.shared.postIntakeData(
                intakeDataArray: calculatedIntakeDataArray,
                chosenDate: selectedDate ?? Date()
            ) { success in
                    if success {
                        print("Food intake data posted successfully")
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        print("Failed to post food intake data")
                    }
                }
        }

    }
    
    func fetchRecentRecord() {
        guard let section = self.sectionIndex else { return }
        FirestoreManager.shared.getFoodSectionData(section: section) { [weak self] foods in
            guard let strongSelf = self else { return }
            
            strongSelf.recentFoods = foods.map { food in
                var modifiedFood = food
                if modifiedFood.quantity != 0 {
                    modifiedFood.totalCalories = ((modifiedFood.totalCalories * 100) / (modifiedFood.quantity ?? 100) * 10).rounded() / 10
                    modifiedFood.nutrients.carbohydrates = ((modifiedFood.nutrients.carbohydrates * 100) / (modifiedFood.quantity ?? 100) * 10).rounded() / 10
                    modifiedFood.nutrients.protein = ((modifiedFood.nutrients.protein * 100) / (modifiedFood.quantity ?? 100) * 10).rounded() / 10
                    modifiedFood.nutrients.fat = ((modifiedFood.nutrients.fat * 100) / (modifiedFood.quantity ?? 100) * 10).rounded() / 10
                    modifiedFood.nutrients.fiber = ((modifiedFood.nutrients.fiber * 100) / (modifiedFood.quantity ?? 100) * 10).rounded() / 10
                }
                return modifiedFood
            }
            
            DispatchQueue.main.async {
                strongSelf.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            }
        }
    }
        
    func calculateIntakeData(input: Food) -> Food? {
        let updatedTotalCalorie = (input.totalCalories * ((input.quantity ?? 100) / 100.0) * 10).rounded() / 10
        let updatedCarbohydrates = (input.nutrients.carbohydrates * ((input.quantity ?? 100) / 100.0) * 10).rounded() / 10
        let updatedProtein = (input.nutrients.protein * ((input.quantity ?? 100) / 100.0) * 10).rounded() / 10
        let updatedFat = (input.nutrients.fat * ((input.quantity ?? 100) / 100.0) * 10).rounded() / 10
        let updatedFiber = (input.nutrients.fiber * ((input.quantity ?? 100) / 100.0) * 10).rounded() / 10
        
        let nutrients = Nutrient(carbohydrates: updatedCarbohydrates, protein: updatedProtein, fat: updatedFat, fiber: updatedFiber)
        
        guard let sectionIndex = self.sectionIndex else {
            fatalError("sectionIndex is nil")
        }
        
        return Food(
            documentID: input.documentID,
            name: input.name,
            totalCalories: updatedTotalCalorie,
            nutrients: nutrients,
            image: input.image,
            quantity: input.quantity,
            section: sectionIndex,
            date: input.date
        )
    }

}

// MARK: - Extension: UITableViewDelegate, UITableViewDataSource

extension AddFoodViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return filteredFoodItems.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: AddFoodMethodCell.self),
                for: indexPath
            )
            guard let addMethodCell = cell as? AddFoodMethodCell else { return cell }
            addMethodCell.delegate = self
            addMethodCell.configureCellForMethod(currentMethod)
            return addMethodCell
            
        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: RecentRecordCell.self),
                for: indexPath
            )
            guard let recentRecordCell = cell as? RecentRecordCell else { return cell }
            if recentFoods.isEmpty {
                recentRecordCell.setupDefaultLabel()
                return recentRecordCell
            } else {
                recentRecordCell.collectionView.delegate = self
                recentRecordCell.collectionView.dataSource = self
                return recentRecordCell
            }
        case 2:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: ResultCell.self),
                for: indexPath
            )
            guard let resultCell = cell as? ResultCell else { return cell }
            let foodResult = filteredFoodItems[indexPath.row]
            resultCell.updateResult(foodResult)
            resultCell.deleteButtonTapped = { [weak self] in
                self?.filteredFoodItems.remove(at: indexPath.row)
            }
            return resultCell
        default:
            break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            tableView.estimatedRowHeight = 300
            return UITableView.automaticDimension
        case 1:
            return 200
        case 2:
            return 180
        default:
            return 0
        }
    }
    
}

// MARK: - CollectionView

extension AddFoodViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recentFoods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: RecordCollectionCell.self),
            for: indexPath)
        guard let collectionViewCell = cell as? RecordCollectionCell else { return cell }
        let recentFood = recentFoods[indexPath.row]
        collectionViewCell.updateResults(recentFood)
        return collectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height
        return CGSize(width: 80, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recentFood = recentFoods[indexPath.row]
        filteredFoodItems.insert(recentFood, at: 0)
    }
}
    
// MARK: - Extension: Search Food Function

extension AddFoodViewController: UISearchBarDelegate, AddFoodMethodCellDelegate {
    
    func cameraButtonDidTapped() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Check if the device has a camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "相機", style: .default) { [weak self] _ in
                self?.presentImagePicker(sourceType: .camera)
            }
            alertController.addAction(cameraAction)
        }
        
        let photoLibraryAction = UIAlertAction(title: "從相簿選取", style: .default) { [weak self] _ in
            self?.presentImagePicker(sourceType: .photoLibrary)
        }
        alertController.addAction(photoLibraryAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func searchBarDidChange(text: String) {
        guard !text.isEmpty else { return }
        loadFood()
        let filterFoods = foodResult.filter { $0.name.lowercased().contains(text.lowercased()) }
        for filterFood in filterFoods {
            filteredFoodItems.insert(filterFood, at: 0)
        }
    }
    
    private func loadFood() {
        FoodDataManager.shared.loadFood { [weak self] (foodItems, error) in
            if let foodItems = foodItems {
                self?.foodResult = foodItems
            } else if let error = error {
                print("Failed to load food data: \(error)")
            }
        }
    }
    
    func textFieldConfirmed(foodResults: [Food]?) {
        guard let foodResults = foodResults else { return }
        for foodResult in foodResults {
            filteredFoodItems.insert(foodResult, at: 0)
        }
    }
    
}

// MARK: - Extension: UIImagePickerController

extension AddFoodViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let cameraVC = CameraViewController()
        guard let image = info[.originalImage] as? UIImage else { return }
        cameraVC.imageView.image = image
        
        // Convert the image for CIImage
        if let ciImage = CIImage(image: image) {
            cameraVC.processImage(ciImage: ciImage)
        } else {
            print("CIImage convert error")
        }
        
        cameraVC.delegate = self
        picker.pushViewController(cameraVC, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - Extension: image recognition data

extension AddFoodViewController: FoodDataDelegate {
    
    func didTappedRetake(_ controller: CameraViewController) {
        controller.dismiss(animated: true) {
            self.presentImagePicker(sourceType: .camera)
        }
    }

    func didReceiveFoodData(name: String, totalCalories: Double, nutrients: Nutrient, image: String) {
        let identifiedFood = Food(
            documentID: "",
            name: name,
            totalCalories: totalCalories,
            nutrients: nutrients,
            image: image,
            quantity: nil,
            section: nil, 
            date: nil
        )
        filteredFoodItems.insert(identifiedFood, at: 0)
    }
    
}
