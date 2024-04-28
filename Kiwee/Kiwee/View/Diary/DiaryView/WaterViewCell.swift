//
//  WaterViewCell.swift
//  Kiwee
//
//  Created by NY on 2024/4/14.
//

import UIKit

class WaterViewCell: UITableViewCell {
    
    func waterSectionConfigure(count: Int) {
        
        contentView.subviews.forEach { subview in
            if subview is UIImageView {
                subview.removeFromSuperview()
            }
        }
        
//        for index in 0..<count {
//            let imageView = UIImageView(frame: CGRect(x: 24 + index * 40, y: 15, width: 50, height: 50))
//            imageView.image = UIImage(named: "Glass")
//            contentView.addSubview(imageView)
//        }
        
        let imageWidth: CGFloat = 50
        let imageHeight: CGFloat = 50
        let startX: CGFloat = 24
        let startY: CGFloat = 15
        let spaceBetweenImages: CGFloat = 40
        let spaceBetweenRows: CGFloat = 10 // Adjust the space between rows as needed
        
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
