//
//  AddFoodViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import UIKit

class AddFoodViewController: UIViewController {
    
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
    
    private var foodResult = [Food]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBottomBlock()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AddFoodMethodCell.self, forCellReuseIdentifier: "AddFoodMethodCell")
//        tableView.register(RecentRecordCell.self, forCellReuseIdentifier: "RecentRecordCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
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
    
    @objc func confirmed() {
        confirmSelection()
    }
    
    func confirmSelection() {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ResultCell else { return }
        guard let foodResult = selectedFoodResult else {
            print("No food result selected")
            return
        }
        
        // Post the intake data to Firebase
        if let quantityText = cell.quantityTextField.text, let quantity = Double(quantityText) {
            // Use the 'quantity' double value here
            let foodInput = IntakeData(
                name: foodResult.name,
                totalCalorie: foodResult.totalCalorie, 
                nutrients: foodResult.nutrients,
                image: foodResult.image,
                quantity: quantity
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
    
    func calculateIntakeData(input: IntakeData) -> IntakeData {
        let updatedTotalCalorie = input.totalCalorie * (input.quantity / 100)
        let updatedCarbohydrates = input.nutrients.carbohydrates * (input.quantity / 100)
        let updatedProtein = input.nutrients.protein * (input.quantity / 100)
        let updatedFat = input.nutrients.fat * (input.quantity / 100)
        let updatedFiber = input.nutrients.fiber * (input.quantity / 100)
        
        let nutrients = Nutrient(carbohydrates: updatedCarbohydrates, protein: updatedProtein, fat: updatedFat, fiber: updatedFiber)
        
        return IntakeData(
            name: input.name,
            totalCalorie: updatedTotalCalorie,
            nutrients: nutrients,
            image: input.image,
            quantity: input.quantity
        )
    }

}

extension AddFoodViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return foodResult.count
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
            return addMethodCell
            
        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: ResultCell.self),
                for: indexPath
            )
            guard let resultCell = cell as? ResultCell else { return cell }
            selectedFoodResult = foodResult[indexPath.row]
            let foodResult = foodResult[indexPath.row]
            resultCell.nameLabel.text = "\(foodResult.name) (每100g)"
            resultCell.totalCalorieLabel.text = "熱量\n\(foodResult.totalCalorie)"
            resultCell.carboLabel.text = "碳水\n\(foodResult.nutrients.carbohydrates)"
            resultCell.proteinLabel.text = "蛋白質\n\(foodResult.nutrients.protein)"
            resultCell.fatLabel.text = "脂肪\n\(foodResult.nutrients.fat)"
            resultCell.fiberLabel.text = "纖維\n\(foodResult.nutrients.fiber)"
            resultCell.foodImage.loadImage(foodResult.image, placeHolder: UIImage(named: "Food_Placeholder"))
            resultCell.quantityTextField.text = "100"
            
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
            return 100
        }
    }
    
}

extension AddFoodViewController: UISearchBarDelegate, AddFoodMethodCellDelegate {
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        guard let searchText = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !searchText.isEmpty else {
//            return
//        }
//        // Call method to perform search with searchText
//        performSearch(searchText: searchText)
//    }
    
    func searchBarDidChange(text: String) {
        FirestoreManager.shared.searchFood(searchText: text) { [weak self] filteredFoodResults in
            self?.foodResult = filteredFoodResults
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        // Reset search and reload data
//        resetSearch()
//    }
}
