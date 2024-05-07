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
        setupUI()
    }
    
    func setupUI() {
        nutrientLabel.applyTitle(size: 17, color: .black)
        descriptionLabel.applyContent(size: 13, color: .black)
        contentLabel.applyTitle(size: 14, color: .black)
        customLabel.applyTitle(size: 14, color: KWColor.darkB)
        
        backgroundColor = KWColor.lightY
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
