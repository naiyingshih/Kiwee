//
//  DiaryViewCell.swift
//  Kiwee
//
//  Created by NY on 2024/4/10.
//

import UIKit

class DiaryViewCell: UITableViewCell {
    @IBOutlet weak var cardOutlineView: UIView!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCellUI()
        self.backgroundColor = UIColor.hexStringToUIColor(hex: "f8f7f2")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {}
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0))
    }
    
    func configureCellUI() {
        calorieLabel.font = UIFont.systemFont(ofSize: 15)
        
        cardOutlineView.backgroundColor = UIColor.hexStringToUIColor(hex: "f4f4f4")
        cardOutlineView.layer.cornerRadius = 10
        cardOutlineView.layer.shadowColor = UIColor.gray.cgColor
        cardOutlineView.layer.shadowOpacity = 0.5
        cardOutlineView.layer.shadowOffset = CGSize(width: 1, height: 1)
        cardOutlineView.layer.shadowRadius = 3
        
        foodImage.contentMode = .scaleAspectFill
    }
    
    func update(_ result: Food) {
        foodImage.loadImage(result.image, placeHolder: UIImage(named: "Food_Placeholder"))
        foodNameLabel.text = result.name
        calorieLabel.text = String(format: "%.0f kcal", result.totalCalories)
    }
    
}
