//
//  ResultCell.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import UIKit

protocol DeleteButtonDelegate: AnyObject {
    func didStartEditingTextField(in cell: UITableViewCell)
    func didEndEditingTextField(in cell: UITableViewCell)
}

class ResultCell: UITableViewCell {
    
    weak var delegate: DeleteButtonDelegate?
    var deleteButtonTapped: (() -> Void)?
    var onQuantityChange: ((Double) -> Void)?
    
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
        quantityTextField.addTarget(self, action: #selector(quantityEndEditing), for: .editingDidEnd)
        quantityTextField.addTarget(self, action: #selector(quantityStartEditing), for: .editingDidBegin)
    }
    
    func setupCardUI() {
        cardView.applyCardStyle()
        deleteButton.tintColor = KWColor.darkG
        quantityTextField.keyboardType = .decimalPad
    }

    @objc func quantityStartEditing() {
        delegate?.didStartEditingTextField(in: self)
    }
    
    @objc func quantityEndEditing() {
        if let text = quantityTextField.text, let quantity = Double(text) {
            onQuantityChange?(quantity)
            delegate?.didEndEditingTextField(in: self)
        }
    }
    
    func updateResult(_ result: Food, quantity: Double) {
        nameLabel.text = "\(result.name) (每100g)"
        totalCalorieLabel.text = "熱量\n\(result.totalCalories)"
        carboLabel.text = "碳水\n\(result.nutrients.carbohydrates)"
        proteinLabel.text = "蛋白\n\(result.nutrients.protein)"
        fatLabel.text = "脂肪\n\(result.nutrients.fat)"
        fiberLabel.text = "纖維\n\(result.nutrients.fiber)"
        foodImage.loadImage(result.image, placeHolder: UIImage(named: "Food_Placeholder"))
        quantityTextField.text = "\(quantity)"
    }
    
    // MARK: - Actions
    @IBAction func deleteResult(_ sender: Any) {
        deleteButtonTapped?()
    }
    
}
