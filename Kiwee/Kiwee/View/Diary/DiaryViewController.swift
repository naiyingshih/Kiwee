//
//  ViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/10.
//

import UIKit

class DiaryViewController: UIViewController, TableViewHeaderDelegate {
    
    var selectedSection: Int?
    
//    private var allFood = [IntakeData]() {
//        didSet {
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
//    }
    var allFood: [[Food]] = Array(repeating: [], count: 5)

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
//    func loadData() {
//        FirestoreManager.shared.getIntakeCard(collectionID: "intake") { foods in
//            self.allFood = [foods]
//        }
//    }
    
    func loadData() {
        FirestoreManager.shared.getIntakeCard(collectionID: "intake") { foods in
            // Assuming you have a way to categorize foods into sections now
            var newAllFood: [[Food]] = Array(repeating: [], count: 5)
            for food in foods {
                guard let section = food.section else { return }
                if section >= 0 && section < newAllFood.count {
                    newAllFood[section].append(food)
                }
            }
            DispatchQueue.main.async {
                self.allFood = newAllFood
                self.tableView.reloadData()
            }
        }
    }
    
    func didTappedAddButton(section: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let addFoodVC = storyboard.instantiateViewController(
            withIdentifier: String(describing: AddFoodViewController.self)
        ) as? AddFoodViewController else { return }
//        addFoodVC.delegate = self
        addFoodVC.sectionIndex = section
        print("===\(String(describing: section))")
        self.navigationController?.pushViewController(addFoodVC, animated: true)
    }

}

// MARK: - Extension: UITableViewDelegate, UITableViewDataSource

extension DiaryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFood[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: DiaryViewCell.self),
            for: indexPath
        )
        guard let diaryCell = cell as? DiaryViewCell else { return cell }
        let foodData = allFood[indexPath.section][indexPath.row]
        diaryCell.cardOutlineView.layer.cornerRadius = 10
        diaryCell.cardOutlineView.layer.borderWidth = 2
        diaryCell.cardOutlineView.layer.borderColor = UIColor.hexStringToUIColor(hex: "1F8A70").cgColor
        diaryCell.foodNameLabel.text = foodData.name
        diaryCell.calorieLabel.text = "\(foodData.totalCalories)"
        diaryCell.foodImage.loadImage(foodData.image, placeHolder: UIImage(named: "Food_Placeholder"))
        diaryCell.foodImage.contentMode = .scaleAspectFill
        return diaryCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = CategoryHeaderView()
        header.section = section
        header.delegate = self
        switch section {
        case 0:
            header.configure(with: UIImage(named: "Food_Placeholder"), labelText: "早餐")
        case 1:
            header.configure(with: UIImage(named: "Food_Placeholder"), labelText: "午餐")
        case 2:
            header.configure(with: UIImage(named: "Food_Placeholder"), labelText: "晚餐")
        case 3:
            header.configure(with: UIImage(named: "Food_Placeholder"), labelText: "點心")
        case 4:
            header.configure(with: UIImage(named: "Food_Placeholder"), labelText: "水")
        default:
            header.configure(with: nil, labelText: "Other Sections")
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }

}

//extension DiaryViewController: AddFoodDelegate {
//    
//    func didAddFood(section: Int, food: Food) {
//        self.allFood[section].append(food)
//        self.tableView.reloadSections(IndexSet(integer: section), with: .automatic)
//    }
//
//}
