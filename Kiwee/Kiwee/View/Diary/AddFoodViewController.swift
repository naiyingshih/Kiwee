//
//  AddFoodViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import UIKit

protocol AddFoodDelegate: AnyObject {
    func didAddFood(section: Int, food: Food)
}

class AddFoodViewController: UIViewController {
    
    weak var delegate: AddFoodDelegate?
    var sectionIndex: Int?
    
    var foodResult: [Food] = []
    var filteredFoodItems: [Food] = []
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
                    self.delegate?.didAddFood(section: index, food: calculatedIntakeData)
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
        let updatedTotalCalorie = input.totalCalories * ((input.quantity ?? 100) / 100.0)
        let updatedCarbohydrates = input.nutrients.carbohydrates * ((input.quantity ?? 100) / 100.0)
        let updatedProtein = input.nutrients.protein * ((input.quantity ?? 100) / 100.0)
        let updatedFat = input.nutrients.fat * ((input.quantity ?? 100) / 100.0)
        let updatedFiber = input.nutrients.fiber * ((input.quantity ?? 100) / 100.0)
        
        let nutrients = Nutrient(carbohydrates: updatedCarbohydrates, protein: updatedProtein, fat: updatedFat, fiber: updatedFiber)
        
        return Food(
            name: input.name,
            totalCalories: updatedTotalCalorie,
            nutrients: nutrients,
            image: input.image,
            quantity: input.quantity, 
            section: sectionIndex!
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
            return addMethodCell
            
        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: ResultCell.self),
                for: indexPath
            )
            guard let resultCell = cell as? ResultCell else { return cell }
            selectedFoodResult = filteredFoodItems[indexPath.row]
            let foodResult = filteredFoodItems[indexPath.row]
            resultCell.nameLabel.text = "\(foodResult.name) (每100g)"
            resultCell.totalCalorieLabel.text = "熱量\n\(foodResult.totalCalories)"
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

// MARK: - Extension: Search Food Function

extension AddFoodViewController: UISearchBarDelegate, AddFoodMethodCellDelegate {
    
    func searchBarDidChange(text: String) {
        filterFoodItems(with: text)
    }
    
    private func filterFoodItems(with searchText: String) {
        guard !searchText.isEmpty else { return }
        loadFood()
        filteredFoodItems = foodResult.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        tableView.reloadData()
    }
    
    private func loadFood() {
        // Load JSON data from file
        if let url = Bundle.main.url(forResource: "FoodData", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                self.foodResult = try decoder.decode([Food].self, from: data)
                self.filteredFoodItems = self.foodResult
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
    }
    
}
