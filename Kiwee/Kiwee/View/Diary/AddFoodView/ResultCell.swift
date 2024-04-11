//
//  ResultCell.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import UIKit

class ResultCell: UITableViewCell {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var totalCalorieLabel: UILabel!
    @IBOutlet weak var carboLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var fiberLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {}
}
