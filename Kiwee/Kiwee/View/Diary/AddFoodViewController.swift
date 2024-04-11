//
//  AddFoodViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import UIKit

class AddFoodViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageRecognizeButton: UIButton!
    @IBOutlet weak var searchFoodButton: UIButton!
    @IBOutlet weak var manualButton: UIButton!
    
    private var foodResult = [Food]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(AddFoodMethodCell.self, forCellReuseIdentifier: "AddFoodMethodCell")
//        tableView.register(RecentRecordCell.self, forCellReuseIdentifier: "RecentRecordCell")
    }
    
    func loadData() {
        FirestoreManager.shared.get(collectionID: "foods") { foods in
              self.foodResult = foods
          }
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
            return addMethodCell
            
        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: ResultCell.self),
                for: indexPath
            )
            guard let resultCell = cell as? ResultCell else { return cell }
            let foodResult = foodResult[indexPath.row]
            resultCell.nameLabel.text = foodResult.name
            resultCell.totalCalorieLabel.text = "熱量\n\(foodResult.totalCalorie)"
            resultCell.carboLabel.text = "碳水\n\(foodResult.nutrients.carbohydrates)"
            resultCell.proteinLabel.text = "蛋白質\n\(foodResult.nutrients.protein)"
            resultCell.fatLabel.text = "脂肪\n\(foodResult.nutrients.fat)"
            resultCell.fiberLabel.text = "纖維\n\(foodResult.nutrients.fiber)"
            resultCell.foodImage.loadImage(foodResult.image, placeHolder: UIImage(named: "Food_Placeholder"))
            
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
