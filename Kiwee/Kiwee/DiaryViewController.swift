//
//  ViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/10.
//

import UIKit

class DiaryViewController: UIViewController {
    
    private var allFood = [Food]() {
        didSet {
            DispatchQueue.main.async {
                self.foods = self.allFood
            }
        }
    }
    
    var foods = [Food]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func loadData() {
        FirestoreManager.shared.get(collectionID: "foods") { foods in
              self.allFood = foods
          }
      }

}

extension DiaryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: DiaryViewCell.self),
            for: indexPath
        )
        guard let diaryCell = cell as? DiaryViewCell else { return cell }
        let foodData = foods[indexPath.row]
        diaryCell.cardOutlineView.layer.cornerRadius = 10
        diaryCell.cardOutlineView.layer.borderWidth = 2
        diaryCell.cardOutlineView.layer.borderColor = UIColor.hexStringToUIColor(hex: "1F8A70").cgColor
        diaryCell.foodNameLabel.text = foodData.name
        diaryCell.calorieLabel.text = "\(foodData.totalCalorie)"
        diaryCell.foodImage.loadImage(foodData.image, placeHolder: UIImage(named: "Food_Placeholder"))
        diaryCell.foodImage.contentMode = .scaleAspectFill
        return diaryCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

}
