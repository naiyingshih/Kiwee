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
                self.tableView.reloadSections(IndexSet(integer: 4), with: .none)
            }
        }
    }
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.layer.cornerRadius = 10
        picker.layer.backgroundColor = UIColor.hexStringToUIColor(hex: "FFE11A").cgColor
        picker.tintColor = UIColor.hexStringToUIColor(hex: "1F8A70")
        picker.sizeToFit()
        picker.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.hexStringToUIColor(hex: "f8f7f2")
        tableView.backgroundColor = UIColor.hexStringToUIColor(hex: "f8f7f2")
        self.navigationItem.titleView = datePicker
        loadData(for: Date())
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.sectionHeaderTopPadding = 8
//        UIView.setAnimationsEnabled(false)
    }

    @objc func dateChanged(datePicker: UIDatePicker) {
        loadData(for: datePicker.date)
    }
    
    func loadData(for date: Date) {
        FirestoreManager.shared.getIntakeCard(
            collectionID: "intake", 
            chosenDate: datePicker.date
        ) { foods, water in
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
            
            FirestoreManager.shared.postWaterCount(
                waterCount: waterCount,
                chosenDate: datePicker.date
            ) { success in
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
            addFoodVC.selectedDate = datePicker.date
            self.navigationController?.pushViewController(addFoodVC, animated: true)
        }
    }
    
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
            waterCell.waterSectionConfigure(count: waterCount)
//            waterCell.backgroundColor = UIColor.hexStringToUIColor(hex: "e8e4d3")
            return waterCell

        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: DiaryViewCell.self),
                for: indexPath
            )
            guard let diaryCell = cell as? DiaryViewCell else { return cell }
            let foodData = allFood[indexPath.section][indexPath.row]
            diaryCell.update(foodData)
            return diaryCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 4 {
            return 200
        } else {
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = CategoryHeaderView()
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
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 4 {
            let detailView = DetailView()
            if let cell = tableView.cellForRow(at: indexPath) {
                let cellFrameInSuperview = tableView.convert(cell.frame, to: self.view)
                let tapLocation = CGPoint(x: cellFrameInSuperview.midX, y: cellFrameInSuperview.midY)
                let food = allFood[indexPath.section][indexPath.row]
                detailView.configureView(food)
                detailView.presentView(onView: self.view, atTapLocation: tapLocation)
            }
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section >= 0 && indexPath.section <= 3 {
                let foodItem = allFood[indexPath.section][indexPath.row]
                let documentID = foodItem.documentID ?? ""
                
                FirestoreManager.shared.deleteDocument(collectionID: "intake", documentID: documentID) { success in
                    DispatchQueue.main.async {
                        if success {
                            print("Document successfully removed!")
                            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
                        } else {
                            print("Error removing document")
                        }
                    }
                }
            } else if indexPath.section == 4 {
                FirestoreManager.shared.resetWaterCount(chosenDate: datePicker.date) { success in
                    DispatchQueue.main.async {
                        if success {
                            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
                            print("water successfully reset")
                        } else {
                            print("Error removing document")
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        if indexPath.section == 4 {
            return "重設"
        } else {
            return "刪除"
        }
    }
    
}
