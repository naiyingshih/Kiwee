//
//  WaterViewCell.swift
//  Kiwee
//
//  Created by NY on 2024/4/14.
//

import UIKit

class WaterViewCell: UITableViewCell {
    
    func waterSectionConfigure(count: Int) {
        // Remove existing subviews
//        for subview in self.subviews {
//            subview.removeFromSuperview()
//        }
        for index in 0..<count {
            let imageView = UIImageView(frame: CGRect(x: 24 + index * 40, y: 15, width: 50, height: 50))
            imageView.image = UIImage(named: "Glass")
            contentView.addSubview(imageView)
        }
    }
    
}
