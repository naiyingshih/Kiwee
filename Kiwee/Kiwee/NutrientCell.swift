//
//  NutrientCell.swift
//  Kiwee
//
//  Created by NY on 2024/5/4.
//

import UIKit

class NutrientCell: UICollectionViewCell {
    
    @IBOutlet weak var nutrientLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var customLabel: UILabel!
    @IBOutlet weak var nutrientImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.hexStringToUIColor(hex: "ffd500")
        layer.cornerRadius = 20
    }
    
    func configureCell(with model: NutrientCardModel) {
        nutrientLabel.text = model.nutrient
        descriptionLabel.text = model.description
        contentLabel.text = model.content
        customLabel.text = model.customInfo
        nutrientImageView.image = UIImage(named: model.image)
    }
    
}
