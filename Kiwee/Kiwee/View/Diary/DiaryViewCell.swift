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
    
    func configureCellUI() {
        cardOutlineView.layer.cornerRadius = 10
        cardOutlineView.layer.borderWidth = 2
        cardOutlineView.layer.borderColor = UIColor.hexStringToUIColor(hex: "1F8A70").cgColor
        foodImage.contentMode = .scaleAspectFill
    }
}