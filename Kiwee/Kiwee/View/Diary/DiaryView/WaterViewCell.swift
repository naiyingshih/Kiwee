//
//  WaterViewCell.swift
//  Kiwee
//
//  Created by NY on 2024/4/14.
//

import UIKit

class WaterViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = KWColor.background
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = KWColor.background
    }
    
    func waterSectionConfigure(count: Int) {
        
        contentView.subviews.forEach { subview in
            if subview is UIImageView {
                subview.removeFromSuperview()
            }
        }
        
        let imageWidth: CGFloat = 50
        let imageHeight: CGFloat = 50
        let startX: CGFloat = 24
        let startY: CGFloat = 15
        let spaceBetweenImages: CGFloat = 40
        let spaceBetweenRows: CGFloat = 10
        
        for index in 0..<count {
            let row = index / 8 // Calculate current row based on index
            let column = index % 8 // Calculate current column based on index
            
            let xPosition = startX + CGFloat(column) * (imageWidth + spaceBetweenImages - imageWidth)
            let yPosition = startY + CGFloat(row) * (imageHeight + spaceBetweenRows)
            
            let imageView = UIImageView(frame: CGRect(x: xPosition, y: yPosition, width: imageWidth, height: imageHeight))
            imageView.image = UIImage(named: "Glass")
            contentView.addSubview(imageView)
        }
    }
    
}
