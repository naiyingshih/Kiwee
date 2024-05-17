//
//  AddFoodViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import UIKit
import Vision

class AddFoodViewController: UIViewController {
    
    let viewModel = AddFoodViewModel()
    
    private var isUpdatingFromViewModel = false
    private var isEditingTextField = false
    
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
        viewModel.fetchRecentRecord()
        viewModel.delegate = self
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
        viewModel.currentMethod = .imageRecognition
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
    
    // MARK: - Actions
    @IBAction func imageRecognizeButtonTapped(_ sender: UIButton) {
        updateButtonColors(selectedButton: sender)
        updateBottomBorder(for: sender)
        viewModel.currentMethod = .imageRecognition
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func searchFoodButtonTapped(_ sender: UIButton) {
        updateButtonColors(selectedButton: sender)
        updateBottomBorder(for: sender)
        viewModel.currentMethod = .search
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func manualButtonTapped(_ sender: UIButton) {
        updateButtonColors(selectedButton: sender)
        updateBottomBorder(for: sender)
        viewModel.currentMethod = .manual
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func updateBottomBorder(for selectedButton: UIButton) {
        // Deactivate the existing centerX constraint
        indicatorCenterXConstraint?.isActive = false
        
        // Create a new centerX constraint to align the indicator with the selected button
        indicatorCenterXConstraint = indicatorView.centerXAnchor.constraint(equalTo: selectedButton.centerXAnchor)
        indicatorCenterXConstraint?.isActive = true
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
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
        viewModel.confirmed { [weak self] rowIndex, _ in
            guard let self = self else { return nil }
            let indexPath = IndexPath(row: rowIndex, section: 2)
            guard let cell = self.tableView.cellForRow(at: indexPath) as? ResultCell,
                  let quantityText = cell.quantityTextField.text,
                  let quantity = Double(quantityText) else {
                print("Could not find cell or invalid quantity for row \(rowIndex)")
                return nil
            }
            return (cell, quantity)
        }
    }
    
}
    
// MARK: - AddFoodViewControllerDelegate
extension AddFoodViewController: AddFoodViewControllerDelegate {

    func didUpdateFilteredFoodItems(_ foodItems: [Food]) {
        
        guard !isUpdatingFromViewModel else { return }
        
        isUpdatingFromViewModel = true
        defer { isUpdatingFromViewModel = false }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            UIView.setAnimationsEnabled(false)
            self.tableView.reloadSections(IndexSet(integer: 2), with: .none)
            
            if !foodItems.isEmpty {
                self.updateConfirmButtonState(isEnabled: true)
                self.badgeLabel.text = "\(foodItems.count)"
                self.badgeLabel.isHidden = false
            } else {
                self.updateConfirmButtonState(isEnabled: false)
                self.badgeLabel.isHidden = true
            }
        }
    }
    
    func didUpdateRecentFoods(_ items: [Food]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
        }
    }
    
    func didConfirmFoodItems(_ foodItems: [Food]) {
        navigationController?.popViewController(animated: true)
    }

}

// MARK: - Extension: UITableViewDelegate, UITableViewDataSource

extension AddFoodViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return viewModel.filteredFoodItems.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddFoodMethodCell.self), for: indexPath)
            guard let addMethodCell = cell as? AddFoodMethodCell else { return cell }
            addMethodCell.delegate = self
            addMethodCell.configureCellForMethod(viewModel.currentMethod)
            addMethodCell.viewModel = viewModel
            
            if !viewModel.searchFoodResult.isEmpty {
                addMethodCell.searchResultCollectionView.reloadData()
                addMethodCell.updateCollectionViewConstraints()
            }
            return addMethodCell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RecentRecordCell.self), for: indexPath)
            guard let recentRecordCell = cell as? RecentRecordCell else { return cell }
            if viewModel.recentFoods.isEmpty {
                recentRecordCell.setupDefaultLabel()
            } else {
                recentRecordCell.setupCollectionView()
                recentRecordCell.viewModel = viewModel
                recentRecordCell.collectionView.reloadData()
            }
            return recentRecordCell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ResultCell.self), for: indexPath)
            guard let resultCell = cell as? ResultCell else { return cell }
            resultCell.delegate = self
            
            let foodResult = viewModel.filteredFoodItems[indexPath.row]
            let identifier = foodResult.generateIdentifier()
            let quantity = viewModel.foodQuantities[identifier] ?? (foodResult.quantity ?? 100)
            resultCell.updateResult(foodResult, quantity: quantity)
            
            resultCell.onQuantityChange = { [weak self, weak resultCell] quantity in
                guard let self = self else { return }
                var foodItem = viewModel.filteredFoodItems[indexPath.row]
                foodItem.quantity = quantity
                viewModel.foodQuantities[foodItem.generateIdentifier()] = quantity
                resultCell?.updateResult(foodItem, quantity: quantity)
            }
            
            resultCell.deleteButtonTapped = { [weak self] in
                self?.viewModel.filteredFoodItems.remove(at: indexPath.row)
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
        let filterFoods = viewModel.foodResult.filter { $0.name.lowercased().contains(text.lowercased()) }
        if filterFoods.isEmpty {
            showNoResultsAlert()
        } else {
            for filterFood in filterFoods {
                viewModel.searchFoodResult.insert(filterFood, at: 0)
            }
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
            }
        }
    }
    
    func removeAllSearchResult() {
        if !viewModel.searchFoodResult.isEmpty {
            viewModel.searchFoodResult.removeAll()
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
            }
        }
    }
    
    private func loadFood() {
        FoodDataManager.shared.loadFood { [weak self] (foodItems, error) in
            if let foodItems = foodItems {
                self?.viewModel.foodResult = foodItems
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
            viewModel.filteredFoodItems.insert(foodResult, at: 0)
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

    func didReceiveFoodData(name: String, totalCalories: Double, nutrients: Food.Nutrient, image: String) {
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
        viewModel.filteredFoodItems.insert(identifiedFood, at: 0)
    }
}
