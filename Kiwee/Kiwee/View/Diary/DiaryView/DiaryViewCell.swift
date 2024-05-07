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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {}
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0))
    }
    
    func configureCellUI() {
        self.backgroundColor = KWColor.background
        foodNameLabel.applyTitle(size: 18, color: .black)
        calorieLabel.applyTitle(size: 18, color: .black)
        cardOutlineView.applyCardStyle()
        foodImage.contentMode = .scaleAspectFill
    }
    
    func update(_ result: Food) {
        foodImage.loadImage(result.image, placeHolder: UIImage(named: "Food_Placeholder"))
        foodNameLabel.text = result.name
        calorieLabel.text = String(format: "%.0f kcal", result.totalCalories)
    }
    
}
