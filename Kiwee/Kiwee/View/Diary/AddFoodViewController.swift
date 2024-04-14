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
            }
        }
    }
    var selectedFoodResult: Food?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageRecognizeButton: UIButton!
    @IBOutlet weak var searchFoodButton: UIButton!
    @IBOutlet weak var manualButton: UIButton!
    
    lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
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
//        tableView.register(RecentRecordCell.self, forCellReuseIdentifier: "RecentRecordCell")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func setupInitialUI() {
        currentMethod = .imageRecognition
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
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
    
    @IBAction func imageRecognizeButtonTapped() {
        currentMethod = .imageRecognition
        filteredFoodItems.removeAll()
    }
    
    @IBAction func searchFoodButtonTapped() {
        currentMethod = .search
        filteredFoodItems.removeAll()
    }
    
    @IBAction func manualButtonTapped() {
        currentMethod = .manual
        filteredFoodItems.removeAll()
    }
    
    @objc func confirmed() {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ResultCell else { return }
        guard let foodResult = selectedFoodResult else {
            print("No food result selected")
            return
        }
        
        // Post the intake data to Firebase
        if let quantityText = cell.quantityTextField.text, let quantity = Double(quantityText) {
            guard let index = self.sectionIndex else { return }
            let foodInput = Food(
                name: foodResult.name,
                totalCalories: foodResult.totalCalories,
                nutrients: foodResult.nutrients,
                image: foodResult.image,
                quantity: quantity, 
                section: index
            )
            let calculatedIntakeData = calculateIntakeData(input: foodInput)
            
            FirestoreManager.shared.postIntakeData(intakeData: calculatedIntakeData) { success in
                if success {
                    print("Intake data posted successfully")
                    self.navigationController?.popViewController(animated: true)
                } else {
                    print("Failed to post intake data")
                }
            }
            
        } else {
            print("Invalid quantity text or conversion failed")
        }
    }
    
    func calculateIntakeData(input: Food) -> Food {
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
            section: sectionIndex
        )
    }

}

// MARK: - Extension: UITableViewDelegate, UITableViewDataSource

extension AddFoodViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
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
                withIdentifier: String(describing: ResultCell.self),
                for: indexPath
            )
            guard let resultCell = cell as? ResultCell else { return cell }
            selectedFoodResult = filteredFoodItems[indexPath.row]
            let foodResult = filteredFoodItems[indexPath.row]
            resultCell.updateResult(foodResult)
            return resultCell
            
        case 2:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: RecentRecordCell.self),
                for: indexPath
            )
            guard let recentRecordCell = cell as? RecentRecordCell else { return cell }
            return recentRecordCell
            
        default:
            break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 180
        } else {
//            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 300
            return UITableView.automaticDimension
//            return 200
        }
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
            section: nil
        )
        filteredFoodItems.append(identifiedFood)
    }
    
}
