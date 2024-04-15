//
//  ViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/10.
//

import UIKit

class DiaryViewController: UIViewController, TableViewHeaderDelegate {

    var allFood: [[Food]] = Array(repeating: [], count: 5)
    var waterCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 4), with: .automatic)
//                self.checkAndResetWaterCount()
            }
        }
    }
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.sizeToFit()
        picker.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = datePicker
        loadData(for: Date())
        tableView.delegate = self
        tableView.dataSource = self
    }

    @objc func dateChanged(datePicker: UIDatePicker) {
        let selectedDate = datePicker.date
        loadData(for: selectedDate)
    }
    
    func loadData(for date: Date) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        FirestoreManager.shared.getIntakeCard(
            collectionID: "intake", startOfDay: startOfDay,
            endOfDay: endOfDay) { foods, water in
                self.organizeAndDisplayFoods(foods: foods)
                self.waterCount = water
                print("===foods:\(foods)")
                print("===water:\(water)")
            }
    }
    
    private func organizeAndDisplayFoods(foods: [Food]) {
        var newAllFood: [[Food]] = Array(repeating: [], count: 5)
        for food in foods {
            guard let section = food.section,
                  section >= 0,
                  section < newAllFood.count else { continue }
            newAllFood[section].append(food)
        }
        DispatchQueue.main.async {
            self.allFood = newAllFood
            print("\(self.allFood)")
            self.tableView.reloadData()
        }
    }
    
    func didTappedAddButton(section: Int) {
        if section == 4 {
            waterCount += 1
            
            FirestoreManager.shared.postWaterCount(waterCount: waterCount) { success in
                if success {
                    print("water intake data posted successfully, water count = \(self.waterCount)")
                    self.navigationController?.popViewController(animated: true)
                } else {
                    print("Failed to post water intake data")
                }
            }
            
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let addFoodVC = storyboard.instantiateViewController(
                withIdentifier: String(describing: AddFoodViewController.self)
            ) as? AddFoodViewController else { return }
            addFoodVC.sectionIndex = section
            self.navigationController?.pushViewController(addFoodVC, animated: true)
        }
    }
    
//    func checkAndResetWaterCount() {
//        if let storedArray = UserDefaults.standard.array(forKey: "waterIntakeQuantityTimestamp"),
//            storedArray.count == 2,
//           let storedTimestamp = storedArray[1] as? Date {
//            if !Calendar.current.isDateInToday(storedTimestamp) {
//                UserDefaults.standard.set([0, Date()], forKey: "waterIntakeQuantityTimestamp")
//            }
//        }
//    }
    
}

// MARK: - Extension: UITableViewDelegate, UITableViewDataSource

extension DiaryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 4 {
            return 1
        } else {
            return allFood[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: WaterViewCell.self),
                for: indexPath
            )
            guard let waterCell = cell as? WaterViewCell else { return cell }
//            let waterCount = UserDefaults.standard.integer(forKey: "waterIntakeQuantity")
            waterCell.waterSectionConfigure(count: waterCount)
            return waterCell

        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: DiaryViewCell.self),
                for: indexPath
            )
            guard let diaryCell = cell as? DiaryViewCell else { return cell }
            let foodData = allFood[indexPath.section][indexPath.row]
            diaryCell.configureCellUI()
            diaryCell.foodNameLabel.text = foodData.name
            diaryCell.calorieLabel.text = "熱量：\(foodData.totalCalories) kcal"
            diaryCell.foodImage.loadImage(foodData.image, placeHolder: UIImage(named: "Food_Placeholder"))
            return diaryCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = CategoryHeaderView()
        header.backgroundColor = UIColor.hexStringToUIColor(hex: "BEDB39")
        header.section = section
        header.delegate = self
        switch section {
        case 0:
            header.configure(with: UIImage(named: "Breakfast"), labelText: "早餐")
        case 1:
            header.configure(with: UIImage(named: "Lunch"), labelText: "午餐")
        case 2:
            header.configure(with: UIImage(named: "Dinner"), labelText: "晚餐")
        case 3:
            header.configure(with: UIImage(named: "Snack"), labelText: "點心")
        case 4:
            header.configure(with: UIImage(named: "Water"), labelText: "水")
        default:
            header.configure(with: nil, labelText: "Other Sections")
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }

}
