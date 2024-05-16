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
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                UIView.setAnimationsEnabled(false)
                tableView.reloadSections(IndexSet(integer: 2), with: .none)
                
                if !filteredFoodItems.isEmpty {
                    updateConfirmButtonState(isEnabled: true)
                    badgeLabel.text = "\(filteredFoodItems.count)"
                    badgeLabel.isHidden = false
                } else {
                    updateConfirmButtonState(isEnabled: false)
                    badgeLabel.isHidden = true
                }
            }
        }
    }
    var searchFoodResult: [Food] = []
    var recentFoods: [Food] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
            }
        }
    }
    var selectedDate: Date?
    var foodQuantities: [String: Double] = [:]
    var isEditingTextField = false
    
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
        view.backgroundColor = KWColor.background
        view.addTopBorder(color: .lightGray, width: 0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("確認加入", for: .normal)
        button.applyPrimaryStyle(size: 17)
        button.addTarget(self, action: #selector(confirmed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var badgeLabel: UILabel = {
        let badge = UILabel()
        badge.backgroundColor = KWColor.lightY
        badge.applyContent(size: 15, color: KWColor.darkB)
        badge.textAlignment = .center
        badge.layer.cornerRadius = 15
        badge.layer.masksToBounds = true
        badge.translatesAutoresizingMaskIntoConstraints = false
        return badge
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBottomBlock()
        setupInitialUI()
        setupNavigationItemUI()
        setupTableView()
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
    
    // MARK: - UI Setting Functions
    func setupInitialUI() {
        view.backgroundColor = KWColor.darkB
        view.addSubview(indicatorView)
        indicatorView.backgroundColor = KWColor.lightY
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorWidthConstraint = indicatorView.widthAnchor.constraint(equalTo: imageRecognizeButton.widthAnchor)
        indicatorCenterXConstraint = indicatorView.centerXAnchor.constraint(equalTo: imageRecognizeButton.centerXAnchor)
        NSLayoutConstraint.activate([
            indicatorWidthConstraint!,
            indicatorCenterXConstraint!,
            indicatorView.bottomAnchor.constraint(equalTo: underlineView.bottomAnchor),
            indicatorView.heightAnchor.constraint(equalToConstant: 2.5)
        ])

        buttonStackView.backgroundColor = KWColor.darkB
        imageRecognizeButton.tintColor = .white
        searchFoodButton.tintColor = .lightGray
        manualButton.tintColor = .lightGray
        updateConfirmButtonState(isEnabled: false)
        currentMethod = .imageRecognition
    }
    
    func setupNavigationItemUI() {
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(navigateBack))
        barButtonItem.tintColor = KWColor.lightY
        navigationItem.leftBarButtonItem = barButtonItem
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AddFoodMethodCell.self, forCellReuseIdentifier: "AddFoodMethodCell")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
    }
    
    func setupBottomBlock() {
        view.addSubview(bottomView)
        bottomView.addSubview(confirmButton)
        bottomView.addSubview(badgeLabel)
        
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 100),
            
            confirmButton.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            confirmButton.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 24),
            confirmButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -24),
            confirmButton.heightAnchor.constraint(equalToConstant: 48),
            
            badgeLabel.topAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -10),
            badgeLabel.leadingAnchor.constraint(equalTo: confirmButton.trailingAnchor, constant: -20),
            badgeLabel.widthAnchor.constraint(equalToConstant: 30),
            badgeLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        // Initially hide the badge
        badgeLabel.isHidden = true
    }
    
    func updateConfirmButtonState(isEnabled: Bool) {
        ButtonManager.updateButtonEnableStatus(for: confirmButton, enabled: isEnabled)
    }
    
    @IBAction func imageRecognizeButtonTapped(_ sender: UIButton) {
        updateButtonColors(selectedButton: sender)
        updateBottomBorder(for: sender)
        currentMethod = .imageRecognition
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func searchFoodButtonTapped(_ sender: UIButton) {
        updateButtonColors(selectedButton: sender)
        updateBottomBorder(for: sender)
        currentMethod = .search
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func manualButtonTapped(_ sender: UIButton) {
        updateButtonColors(selectedButton: sender)
        updateBottomBorder(for: sender)
        currentMethod = .manual
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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
        guard !filteredFoodItems.isEmpty else { return }
        guard let index = self.sectionIndex else { return }
        var calculatedIntakeDataArray: [Food] = []
        
        for (rowIndex, filteredFoodItem) in filteredFoodItems.enumerated() {
            let indexPath = IndexPath(row: rowIndex, section: 2)
            guard let cell = tableView.cellForRow(at: indexPath) as? ResultCell,
                  let quantityText = cell.quantityTextField.text,
                  let quantity = Double(quantityText) else {
                print("Could not find cell or invalid quantity for row \(rowIndex)")
                continue
            }
            
            let foodInput = Food(documentID: filteredFoodItem.documentID,
                                 name: filteredFoodItem.name,
                                 totalCalories: filteredFoodItem.totalCalories,
                                 nutrients: filteredFoodItem.nutrients,
                                 image: filteredFoodItem.image,
                                 quantity: quantity,
                                 section: index,
                                 date: filteredFoodItem.date)
            
            if let calculatedIntakeData = calculateIntakeData(input: foodInput) {
                calculatedIntakeDataArray.append(calculatedIntakeData)
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
//            let cell2 = AddFoodMethodCell()
            guard let addMethodCell = cell as? AddFoodMethodCell else { return cell }
            addMethodCell.delegate = self
            addMethodCell.configureCellForMethod(currentMethod)
            addMethodCell.collectionView.delegate = self
            addMethodCell.collectionView.dataSource = self
            if !searchFoodResult.isEmpty {
                addMethodCell.collectionView.reloadData()
                addMethodCell.updateCollectionViewConstraints()
            }
            return addMethodCell
            
        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: RecentRecordCell.self),
                for: indexPath
            )
            guard let recentRecordCell = cell as? RecentRecordCell else { return cell }
            if recentFoods.isEmpty {
                recentRecordCell.setupDefaultLabel()
            } else {
                recentRecordCell.setupCollectionView()
                recentRecordCell.collectionView.delegate = self
                recentRecordCell.collectionView.dataSource = self
                recentRecordCell.collectionView.reloadData()
            }
            return recentRecordCell
        case 2:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: ResultCell.self),
                for: indexPath
            )
            guard let resultCell = cell as? ResultCell else { return cell }
            resultCell.delegate = self
            
            let foodResult = filteredFoodItems[indexPath.row]
            let identifier = foodResult.generateIdentifier()
            let quantity = foodQuantities[identifier] ?? (foodResult.quantity ?? 100)
            resultCell.updateResult(foodResult, quantity: quantity)
            
            resultCell.onQuantityChange = { [weak self, weak resultCell] quantity in
                guard let self = self else { return }
                var foodItem = self.filteredFoodItems[indexPath.row]
                foodItem.quantity = quantity
                self.foodQuantities[foodItem.generateIdentifier()] = quantity
                resultCell?.updateResult(foodItem, quantity: quantity)
            }
            
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

// MARK: - DeleteButtonDelegate

extension AddFoodViewController: DeleteButtonDelegate {
    func didStartEditingTextField(in cell: UITableViewCell) {
        isEditingTextField = true
        updateDismissButtons()
    }

    func didEndEditingTextField(in cell: UITableViewCell) {
        isEditingTextField = false
        updateDismissButtons()
    }
    
    func updateDismissButtons() {
        for case let cell as ResultCell in tableView.visibleCells {
            cell.deleteButton.isEnabled = !isEditingTextField
        }
    }
}

// MARK: - CollectionView

extension AddFoodViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 1:
            return searchFoodResult.count
        case 2:
            return recentFoods.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 1:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: SearchListCollectionViewCell.self),
                for: indexPath)
            guard let searchCollectionViewCell = cell as? SearchListCollectionViewCell else { return cell }
            let searchedFood = searchFoodResult[indexPath.row]
            searchCollectionViewCell.delegate = self
            searchCollectionViewCell.updateResults(searchedFood)
            return searchCollectionViewCell
        case 2:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: RecordCollectionCell.self),
                for: indexPath)
            guard let recentCollectionViewCell = cell as? RecordCollectionCell else { return cell }
            let recentFood = recentFoods[indexPath.row]
            recentCollectionViewCell.updateResults(recentFood)
            return recentCollectionViewCell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView.tag {
        case 1:
            return CGSize(width: 320, height: 30)
        case 2:
            let height = collectionView.bounds.height
            return CGSize(width: 80, height: height)
        default:
            return CGSize()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case 1:
            let selectedFood = searchFoodResult[indexPath.row]
            filteredFoodItems.insert(selectedFood, at: 0)
        case 2:
            let recentFood = recentFoods[indexPath.row]
            filteredFoodItems.insert(recentFood, at: 0)
        default:
            return
        }
    }
    
}
    
// MARK: - Extension: Search Food Function

extension AddFoodViewController: UISearchBarDelegate, AddFoodMethodCellDelegate {
    
    func cameraButtonDidTapped() {
        showImagePickerAlert()
    }
    
    func showImagePickerAlert() {
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
        loadFood()
        let filterFoods = foodResult.filter { $0.name.lowercased().contains(text.lowercased()) }
        if filterFoods.isEmpty {
            showNoResultsAlert()
        } else {
            for filterFood in filterFoods {
                searchFoodResult.insert(filterFood, at: 0)
            }
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
            }
        }
    }
    
    func removeAllSearchResult() {
        if !searchFoodResult.isEmpty {
            searchFoodResult.removeAll()
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
            }
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
    
    private func showNoResultsAlert() {
        let alert = UIAlertController(title: "查無相關結果！", message: "很抱歉，請重新搜尋或嘗試其他方法", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確認", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
            DispatchQueue.main.async {
                self.showImagePickerAlert()
            }
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
