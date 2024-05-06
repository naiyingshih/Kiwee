//
//  ResultCell.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import UIKit

class ResultCell: UITableViewCell {
    
    var deleteButtonTapped: (() -> Void)?
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var totalCalorieLabel: UILabel!
    @IBOutlet weak var carboLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var fiberLabel: UILabel!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func setSelected(_ selected: Bool, animated: Bool) {}

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCardUI()
    }
    
    func setupCardUI() {
        cardView.applyCardStyle()
        deleteButton.tintColor = KWColor.darkG
        quantityTextField.keyboardType = .decimalPad
    }
    
    func updateResult(_ result: Food) {
        nameLabel.text = "\(result.name) (每100g)"
        totalCalorieLabel.text = "熱量\n\(result.totalCalories)"
        carboLabel.text = "碳水\n\(result.nutrients.carbohydrates)"
        proteinLabel.text = "蛋白\n\(result.nutrients.protein)"
        fatLabel.text = "脂肪\n\(result.nutrients.fat)"
        fiberLabel.text = "纖維\n\(result.nutrients.fiber)"
        foodImage.loadImage(result.image, placeHolder: UIImage(named: "Food_Placeholder"))
        quantityTextField.text = "\(result.quantity ?? 100)"
    }
    
    // MARK: - Actions
    @IBAction func deleteResult(_ sender: Any) {
        deleteButtonTapped?()
    }
    
}
