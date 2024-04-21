//
//  AddFoodViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import UIKit

class AddFoodViewController: UIViewController {
    
    var sectionIndex: Int?
    var currentMethod: AddFoodMethod?
    
    var foodResult: [Food] = []
    var filteredFoodItems: [Food] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.confirmButton.isEnabled = true
                self.confirmButton.alpha = 1.0
            }
        }
    }
    var recentFoods: [Food] = []
    var selectedDate: Date?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageRecognizeButton: UIButton!
    @IBOutlet weak var searchFoodButton: UIButton!
    @IBOutlet weak var manualButton: UIButton!
    
    lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hexStringToUIColor(hex: "1F8A70")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("確認加入", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(confirmed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBottomBlock()
        setupInitialUI()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AddFoodMethodCell.self, forCellReuseIdentifier: "AddFoodMethodCell")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
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
        confirmButton.isEnabled = false
        confirmButton.alpha = 0.3
        currentMethod = .imageRecognition
    }
    
    func setupBottomBlock() {
        view.addSubview(bottomView)
        bottomView.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 100),
            
            confirmButton.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            confirmButton.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            confirmButton.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 24),
            confirmButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -24),
            confirmButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    func fetchRecentRecord() {
        guard let secion = self.sectionIndex else { return }
        FirestoreManager.shared.getFoodSectionData(section: secion) { [weak self] foods in
            self?.recentFoods = foods
            DispatchQueue.main.async {
                self?.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            }
        }
    }
    
    @IBAction func imageRecognizeButtonTapped() {
        currentMethod = .imageRecognition
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    @IBAction func searchFoodButtonTapped() {
        currentMethod = .search
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    @IBAction func manualButtonTapped() {
        currentMethod = .manual
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
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
                let foodInput = Food(name: filteredFoodItem.name,
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
            recentRecordCell.collectionView.delegate = self
            recentRecordCell.collectionView.dataSource = self
            return recentRecordCell
            
        case 2:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: ResultCell.self),
                for: indexPath
            )
            guard let resultCell = cell as? ResultCell else { return cell }
            let foodResult = filteredFoodItems[indexPath.row]
            resultCell.updateResult(foodResult)
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
            return 250
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
        filteredFoodItems.append(recentFood)
    }
}
    
// MARK: - Extension: Search Food Function

extension AddFoodViewController: UISearchBarDelegate, AddFoodMethodCellDelegate {
    
    func cameraButtonDidTapped() {
        let cameraVC = CameraViewController()
        cameraVC.delegate = self
        self.navigationController?.pushViewController(cameraVC, animated: false)
    }
    
    func searchBarDidChange(text: String) {
        guard !text.isEmpty else { return }
        loadFood()
        filteredFoodItems = foodResult.filter { $0.name.lowercased().contains(text.lowercased()) }
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
            filteredFoodItems.append(foodResult)
        }
    }
    
}

// MARK: - Extension: image recognition data

extension AddFoodViewController: FoodDataDelegate {
    
    func didReceiveFoodData(name: String, totalCalories: Double, nutrients: Nutrient, image: String) {
        let identifiedFood = Food(
            name: name,
            totalCalories: totalCalories,
            nutrients: nutrients,
            image: image,
            quantity: nil,
            section: nil, 
            date: nil
        )
        filteredFoodItems.append(identifiedFood)
    }
    
}
